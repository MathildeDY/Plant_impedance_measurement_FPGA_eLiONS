library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity msec_counter is
	Port(
		clk : in std_logic;
		arstn : in std_logic;
		en : out std_logic
	);
end msec_counter;

architecture behavioral of msec_counter is

signal pulses : unsigned (15 downto 0) := (others => '0');
constant ms_CLK_FREQ : integer				:= 48000; --CLK_FREQ / 1000 to have ms

begin

process(arstn, clk)
	begin
		if arstn = '0' then --reset
			pulses <= (others => '0');
			en <= '0';
		elsif rising_edge(clk) then
			if pulses = to_unsigned(ms_CLK_FREQ-1,16) then -- 1 msec
				en <= '1';
				pulses <= (others => '0');
			else 
				en <= '0';
				pulses <= pulses + 1;
			end if;
		end if;
end process;


end architecture;