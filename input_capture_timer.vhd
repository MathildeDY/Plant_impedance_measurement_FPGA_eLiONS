library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity input_capture_timer is 
port (
		clk     : in  STD_LOGIC;   
		ongoing_measurements : in std_logic;
		measurement_done : in std_logic;
		powergating : in std_logic;
		arstn : in std_logic;
		analog_in : in std_logic;
		ticks : out unsigned(15 downto 0);
		edges_reached : out std_logic;
		stm_interrupt : out std_logic
      );
end input_capture_timer; 

architecture beh of input_capture_timer is 

constant MY_N_FRONTS : unsigned(7 downto 0) := to_unsigned(128,8);
constant NB_SAMPLES : integer := 7; -- 2^7 = 128
constant N_AVERAGE_EDGES : unsigned(3 downto 0) := to_unsigned(10,4); -- Ignore first N measures for accuracy

signal meas_count : unsigned(7 downto 0) := (others => '0');
signal ignored_edges : unsigned(3 downto 0) := (others => '0');
signal freq_accumulator : unsigned(31 downto 0) := (others => '0');
signal timer_counter : unsigned(15 downto 0) := (others => '0');
signal old_value : unsigned(15 downto 0) := (others => '0');
signal measure_on : std_logic := '0';
signal edges_left : std_logic := '1';

-- Synchronization
signal sig_meta      : std_logic := '0';
signal sig_sync      : std_logic := '0';
signal sig_prev      : std_logic := '0';

begin

process(clk, arstn)
	variable diff : unsigned(15 downto 0) := (others => '0');
	begin
		if (arstn = '0') then
			meas_count <= (others => '0');
			freq_accumulator <= (others => '0'); 
			timer_counter <= (others => '0'); 
			ignored_edges <= (others => '0'); 
			old_value <= (others => '0');
			edges_left <= '1';
			
			
		elsif rising_edge(clk) then
			measure_on <= (ongoing_measurements AND edges_left);
			edges_reached <= not edges_left;
			
			
			if (measure_on = '1') then -- do measure
				-- timer
				timer_counter <= timer_counter + 1;
				
				-- input synchronizer
				sig_meta <= analog_in;
            sig_sync <= sig_meta;
            sig_prev <= sig_sync;
				
				-- Rising edge detection
				if (sig_prev = '0' and sig_sync = '1') then
				
					-- Ignore first capture
					if (old_value /= 0) then
						
						-- Get ticks
						if (timer_counter >= old_value) then
							diff := timer_counter - old_value;
						else -- with overflow
							diff := to_unsigned(65535,16) - old_value + timer_counter;
						end if;
						
						-- Ignore a fixed number of measures for the accuracy
						if (ignored_edges <= N_AVERAGE_EDGES-1) then 
							ignored_edges <= ignored_edges + 1;
						-- Stop after a fixed number of samples
						elsif (meas_count <= MY_N_FRONTS) then
							freq_accumulator <= freq_accumulator + resize(diff,32);
							meas_count <= meas_count + 1;
							if (meas_count = MY_N_FRONTS-1) then
								edges_left <= '0';
							end if;
						end if;
						
					end if;
					old_value <= timer_counter;
					
				end if;
				
			elsif (ongoing_measurements = '0' and powergating = '1') then --reset
				meas_count <= (others => '0');
				freq_accumulator <= (others => '0'); 
				timer_counter <= (others => '0'); 
				ignored_edges <= (others => '0'); 
				old_value <= (others => '0');
				edges_left <= '1';
			end if;
		end if;
	
end process;

process(clk, arstn)
	begin
		if (arstn = '0') then
			ticks <= (others => '0');
			stm_interrupt <= '0';
		elsif rising_edge(clk) then
			if (measurement_done = '1' and meas_count > 0) then
				ticks <= resize(shift_right(freq_accumulator,NB_SAMPLES),16);
				stm_interrupt <= '1';
			elsif (measurement_done = '0') then
				stm_interrupt <= '0';
			end if;
		end if;
end process;

end beh;