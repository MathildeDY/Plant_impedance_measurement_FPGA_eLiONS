library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UMC_Agrichip1 is
    Port (
	clk: in STD_LOGIC; 
        arstn   : in  STD_LOGIC;
   SW : in std_logic_vector (9 downto 0);
	analog_in : in STD_LOGIC; 
	frequency : out unsigned (15 downto 0);
   load : out std_logic;
	powergating : out std_logic;
	output_sec : out std_logic_vector (11 downto 0);
	output_min : out std_logic_vector (11 downto 0)
    );
end UMC_Agrichip1;

architecture beh of UMC_Agrichip1 is 

component RTC_1M is
    Port (
	clk: in STD_LOGIC; 
   arstn   : in  STD_LOGIC;
   SW : in std_logic_vector (9 downto 0);
	powergating : out STD_LOGIC;
	cnt_en : out STD_LOGIC;
	output_sec : out std_logic_vector (11 downto 0);
	output_min : out std_logic_vector (11 downto 0)
    );
end component;

--component UMC_timer is
--Port (
--	analog_in : in STD_LOGIC;
	--clk: in STD_LOGIC; 
     --   arstn   : in  STD_LOGIC;
--	en : in std_logic;
--	clear : in std_logic;
	--frequency : out unsigned (15 downto 0)
   -- );
--end component;

component input_capture_timer
generic (
	   N : integer  := 16  -- Timer parallelism     
        );

port (     clk     : in  STD_LOGIC;    
	        enable     : in  STD_LOGIC;          
           arstn   : in  STD_LOGIC;           
           analog_in : in  STD_LOGIC;  
			  clear : in std_logic;
           frequency  : out unsigned (N-1 downto 0)  
			  
      );
end component;

signal cnten, power_gating : std_logic; 
signal frequency_buff : unsigned(15 downto 0); 



begin


rtc: RTC_1M port map (clk => clk, arstn => arstn, SW => SW, powergating=> power_gating, cnt_en=>cnten, output_sec => output_sec, output_min => output_min);

extratimer: input_capture_timer port map (clk => clk , enable => cnten, arstn => arstn, analog_in => analog_in, clear => power_gating,  frequency=> frequency_buff );
load <= not(power_gating);
powergating <= power_gating;
frequency <= frequency_buff; 
end architecture; 

