library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RTC_1M is
	Port (
		clk: in STD_LOGIC; 
		arstn   : in  STD_LOGIC;	  
		period : in STD_LOGIC_VECTOR (5 downto 0); -- amount of time (minutes) between every measure
		data_valid : in std_logic;
		edges_reached : in std_logic;
		powergating : out STD_LOGIC;
		cnt_en : out STD_LOGIC;
		done : out std_logic;
		output_sec : out std_logic_vector (11 downto 0);
		output_min : out std_logic_vector (11 downto 0)
    );
end RTC_1M;

architecture beh of RTC_1M is 

component one_sec_counter is
	Port(
		clk : in std_logic;
		arstn : in std_logic;
		en : out std_logic
	);
end component;

signal minutes : unsigned  (5 downto 0) := (others => '0');
signal wait_time : unsigned (5 downto 0) := to_unsigned(15,6); -- 15 min default period
signal seconds : unsigned (5 downto 0) := (others => '0'); 
signal sec_enable : std_logic := '0';
signal reset_time : std_logic := '0';
type state_t is (IDLE, RESET_PHASE, MEASURE, STOP);
signal state : state_t := IDLE;
signal TIM : unsigned(5 downto 0) := (others => '0');

begin 

sec_count : one_sec_counter port map (arstn => arstn, clk => clk, en => sec_enable);

-- Counters
process(arstn, clk)
	begin
		if arstn = '0' then --reset
			minutes <= (others => '0');
			seconds <= (others => '0');
		elsif rising_edge(clk) then
			if reset_time = '1' then -- reset after input capture
				minutes <= (others => '0');
				seconds <= (others => '0');
			elsif sec_enable = '1' then
				if seconds = to_unsigned(59,6) then -- 1 min
					seconds <= (others => '0');
					minutes <= minutes + 1; -- counting minutes
				else 
					seconds <= seconds + 1; -- couting seconds
				end if;
			end if;
		end if;
end process;


-- Input capture control
process(arstn, clk)
	begin
		if arstn = '0' then --reset
			state <= IDLE;
			powergating <= '0';
			cnt_en <= '0';
			done <= '0';
			reset_time <= '0';
			TIM <= (others => '0');
			wait_time <= to_unsigned(2,6);
		elsif rising_edge(clk) then
			if sec_enable = '1' then -- every second
				case state is
					when IDLE => -- waiting for right timing
						reset_time <= '0';
						if data_valid = '1' then
							wait_time <= unsigned(period);
						end if;
						if minutes >= wait_time then -- counts minutes
							state <= RESET_PHASE;
							done <= '0';
						end if;
					when RESET_PHASE => -- input capture reset
						powergating <= '1';
						cnt_en <= '0';
						state <= MEASURE;
					when MEASURE => -- input capture measure
						powergating <= '1';
						cnt_en <= '1';
						if (TIM = to_unsigned(58,6)) then -- Measure for 1 minute (60 sec)
							state <= STOP;
						elsif (edges_reached = '1') then
							state <= STOP;
						else
							TIM <= TIM + 1;
						end if;	
					when STOP => -- input capture stop
						powergating <= '0';
						cnt_en <= '0';
						TIM <= (others => '0');
						state <= IDLE;
						reset_time <= '1'; -- min and sec reset
						done <= '1';
				end case;
			end if;
		end if;
end process;

-- display for debug
output_min <= "000000" & std_logic_vector(minutes);
output_sec <= "000000" & std_logic_vector(seconds);

end architecture; 