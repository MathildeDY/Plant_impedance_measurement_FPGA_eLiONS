library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_sec_counter is
	Port(
		clk : in std_logic;
		arstn : in std_logic;
		en : out std_logic
	);
end one_sec_counter;

architecture behavioral of one_sec_counter is

component msec_counter is
	Port(
		clk : in std_logic;
		arstn : in std_logic;
		en : out std_logic
	);
end component;

signal pulses : unsigned (9 downto 0) := (others => '0');
signal ms_enable : std_logic;
constant ms_to_s : integer := 1000;

begin

ms_count : msec_counter port map (arstn => arstn, clk => clk, en => ms_enable);

process(arstn, clk)
	begin
		if arstn = '0' then --reset
			pulses <= (others => '0');
			en <= '0';
		elsif rising_edge(clk) then
			en <= '0';
			if (ms_enable = '1') then
				if pulses = to_unsigned(ms_to_s-1,10) then -- 1sec
					en <= '1';
					pulses <= (others => '0');
				else 
					pulses <= pulses + 1;
				end if;
			end if;
		end if;
end process;


end architecture;