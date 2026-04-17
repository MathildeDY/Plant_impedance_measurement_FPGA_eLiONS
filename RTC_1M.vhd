

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity RTC_1M is
	Port (
		clk: in STD_LOGIC; 
		arstn   : in  STD_LOGIC;	  
		SW : in STD_LOGIC_VECTOR (9 downto 0);
		powergating : out STD_LOGIC;
		cnt_en : out STD_LOGIC;
		output_sec : out std_logic_vector (11 downto 0)
    );
end RTC_1M;

architecture beh of RTC_1M is 

signal seconds : unsigned  (9 downto 0) := (others => '0');
signal enable : std_logic := '0'; 

component one_sec_counter is
	Port(
		clk : in std_logic;
		arstn : in std_logic;
		en : out std_logic
	);
end component;

begin 

sec_count : one_sec_counter port map (clk => clk, arstn => arstn, en => enable);

process(arstn, clk)
	begin
		if arstn = '0'then --reset
			seconds <= (others => '0');
			powergating <='0';
			cnt_en <= '0';
		elsif rising_edge(clk) then
			if enable = '1' then
				if (seconds + 1) = (unsigned(SW) - 1) then -- input capture reset
					powergating <= '1';
					cnt_en <= '0';
					seconds <= seconds + 1;
				elsif (seconds + 1) = unsigned(SW) then -- measure
					cnt_en <= '1';
					powergating <= '1';
					seconds <= seconds + 1;
				elsif (seconds + 1) >= (unsigned(SW) + 1) then -- stop
					cnt_en <= '0';
					powergating <= '0';
					seconds <= (others => '0');
				else 
					seconds <= seconds + 1; -- count
				end if;
			end if;	
		end if;
end process;

output_sec <= "00" & std_logic_vector(seconds);

end architecture; 