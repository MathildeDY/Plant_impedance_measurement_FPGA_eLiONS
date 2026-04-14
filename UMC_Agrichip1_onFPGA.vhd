library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UMC_Agrichip1_onFPGA is
    Port (
	SW : in std_logic_vector (9 downto 0);
	clk_in: in STD_LOGIC; 
   arstn   : in  STD_LOGIC;
	analog_in : in STD_LOGIC; 
   --scl              : inout std_logic;
   --sda              : inout std_logic;
	lock : out std_logic;
	analog_out : out std_logic;
	HEX5 : out std_logic_vector (0 to 6);
	HEX4 : out std_logic_vector (0 to 6);
	HEX3 : out std_logic_vector (0 to 6);
	HEX2 : out std_logic_vector (0 to 6);
	HEX0 : out  std_logic_vector (0 to 6)
    );
end UMC_Agrichip1_onFPGA;



architecture beh of UMC_Agrichip1_onFPGA is 

component myPLL_0002 is 
Port(
refclk : in std_logic; 
rst : in std_logic;
outclk_0 : out std_logic;
locked : out std_logic
);
end component; 

component UMC_Agrichip1 is 
Port (
	clk: in STD_LOGIC; 
        arstn   : in  STD_LOGIC;
   SW : in std_logic_vector (9 downto 0);
	analog_in : in STD_LOGIC; 
	frequency : out unsigned (15 downto 0);
        load : out std_logic;
	output_sec : out std_logic_vector (11 downto 0)
    );
end component;

--component Agrichip1_TX is 
--port(
--
--	byte0, byte1 : in std_logic_vector (7 downto 0);
--	clk, arstn : in std_logic;
--	--wr_en      : in std_logic;
--	scl              : inout std_logic;
--    sda              : inout std_logic
--);
--end component;


component seven_segment_display is 
port ( 
SW : in std_logic_vector (3 downto 0); 
HEX0 : out std_logic_vector (0 to 6) 
); 
end component; 


signal freq_MSB, freq_LSB : std_logic_vector (7 downto 0);
signal freq : unsigned (15 downto 0);
signal load_f : std_logic;
signal display_sec : std_logic_vector (11 downto 0);
signal disp0 : std_logic_vector (0 to 6);
signal disp2,disp3,disp4,disp5 : std_logic_vector (0 to 6);
signal clk : std_logic;
begin 

PLL : myPLL_0002 port map (refclk => clk_in, rst=> not(arstn), outclk_0=>clk, locked =>lock);
chip: UMC_Agrichip1 port map (SW => SW, clk => clk, arstn => arstn, analog_in => analog_in, load =>load_f, frequency => freq, output_sec => display_sec );

process(clk, arstn)
    begin 
if (arstn = '0') then
freq_MSB <= (others=> '0');
freq_LSB <= (others=> '0');
 elsif (clk'event and clk = '1' and load_f = '1') then    
freq_MSB <= std_logic_vector(freq(15 downto 8));
freq_LSB <= std_logic_vector(freq(7 downto 0));
end if;

end process;

--TX: Agrichip1_TX port map (byte0 => freq_MSB, byte1=> freq_LSB, clk =>clk , arstn =>arstn, scl=> scl, sda =>sda); --wr_en => tx_enable

display5: seven_segment_display port map (SW => freq_MSB(7 downto 4) , HEX0 => disp5);
display4: seven_segment_display port map (SW => freq_MSB(3 downto 0), HEX0 => disp4);
display3: seven_segment_display port map (SW => freq_LSB( 7 downto 4), HEX0 => disp3);
display2: seven_segment_display port map (SW => freq_LSB( 3 downto 0), HEX0 => disp2);
display0: seven_segment_display port map (SW => display_sec(3 downto 0), HEX0 => disp0);

HEX5 <= disp5; 
HEX4 <= disp4; 
HEX3 <= disp3; 
HEX2 <= disp2; 
HEX0 <= disp0;
analog_out <= analog_in;
end beh;