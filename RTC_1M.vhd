

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
		output_sec : out std_logic_vector (11 downto 0);
		output_min : out std_logic_vector (11 downto 0)
    );
end RTC_1M;

architecture beh of RTC_1M is 

component one_min_counter is
		Port (
			arstn : in std_logic;
			clk : in std_logic;
			en : out std_logic;
			sec : out std_logic_vector (5 downto 0)
		);
end component;

signal minutes : unsigned  (5 downto 0) := (others => '0');
signal seconds : std_logic_vector (5 downto 0);
signal enable : std_logic := '0'; 

begin 

min_count : one_min_counter port map (arstn => arstn, clk => clk, en => enable, sec => seconds);


process(arstn, clk)
	begin
		if arstn = '0'then --reset
			minutes <= (others => '0');
			powergating <='0';
			cnt_en <= '0';
		elsif rising_edge(clk) then
			if enable = '1' then
				if (minutes + 1) = (unsigned(SW) - 1) then -- input capture reset
					powergating <= '1';
					cnt_en <= '0';
					minutes <= minutes + 1;
				elsif (minutes + 1) = unsigned(SW) then -- measure
					cnt_en <= '1';
					powergating <= '1';
					minutes <= minutes + 1;
				elsif (minutes + 1) >= (unsigned(SW) + 1) then -- stop
					cnt_en <= '0';
					powergating <= '0';
					minutes <= (others => '0');
				else 
					minutes <= minutes + 1; -- count
				end if;
			end if;	
		end if;
end process;

output_min <= "000000" & std_logic_vector(minutes);
output_sec <= "000000" & seconds;

end architecture; 