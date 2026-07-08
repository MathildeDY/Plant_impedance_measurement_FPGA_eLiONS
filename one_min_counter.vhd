library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity one_min_counter is
		Port (
			arstn : in std_logic;
			clk : in std_logic;
			en : out std_logic;
			sec : out std_logic_vector (5 downto 0) -- Display for debug
		);
end one_min_counter;

architecture behavioral of one_min_counter is

component one_sec_counter is
	Port(
		clk : in std_logic;
		arstn : in std_logic;
		en : out std_logic
	);
end component;

signal seconds : unsigned (5 downto 0) := (others => '0') ;
signal sec_en : std_logic; --enable from one_sec_counter

begin

sec_count : one_sec_counter port map (clk => clk, arstn => arstn, en => sec_en);

process(arstn, clk)
	begin
		if arstn = '0' then 
			seconds <= (others => '0');
			en <= '0';
		elsif rising_edge(clk) then
			en <= '0';
			if sec_en = '1' then
				if seconds = to_unsigned(59,6) then -- 60 sec
					en <= '1';
					seconds <= (others => '0');
				else
					seconds <= seconds + 1; -- keep counting
				end if;
			end if;
		end if;

end process;

sec <= std_logic_vector(seconds);


end architecture;