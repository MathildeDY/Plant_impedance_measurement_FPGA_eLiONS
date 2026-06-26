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

signal pulses : unsigned (25 downto 0) := (others => '0');
constant CLK_FREQ : integer				:= 48000000;

begin

process(arstn, clk)
	begin
		if arstn = '0' then --reset
			pulses <= (others => '0');
			en <= '0';
		elsif rising_edge(clk) then
			if pulses = to_unsigned(CLK_FREQ-1,26) then -- 1sec
				en <= '1';
				pulses <= (others => '0');
			else 
				en <= '0';
				pulses <= pulses + 1;
			end if;
		end if;
end process;


end architecture;