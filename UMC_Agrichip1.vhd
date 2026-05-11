library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UMC_Agrichip1 is
    Port (
	clk: in STD_LOGIC; 
   arstn   : in  STD_LOGIC;
   measure_period : in std_logic_vector (5 downto 0);
	valid_data : in std_logic;
	analog_in : in STD_LOGIC; 
	frequency : out unsigned (15 downto 0);
   load : out std_logic;
	powergating : out std_logic;
	interrupt : out std_logic;
	output_sec : out std_logic_vector (11 downto 0);
	output_min : out std_logic_vector (11 downto 0)
    );
end UMC_Agrichip1;

architecture beh of UMC_Agrichip1 is 

component RTC_1M is
    Port (
	clk: in STD_LOGIC; 
   arstn   : in  STD_LOGIC;
   period : in std_logic_vector (5 downto 0);
	data_valid : in std_logic;
	powergating : out STD_LOGIC;
	cnt_en : out STD_LOGIC;
	output_sec : out std_logic_vector (11 downto 0);
	output_min : out std_logic_vector (11 downto 0)
    );
end component;

component input_capture_timer
generic (
	   N : integer  := 16  -- Timer parallelism     
        );

port (     clk     : in  STD_LOGIC;    
	        enable     : in  STD_LOGIC;          
           arstn   : in  STD_LOGIC;           
           analog_in : in  STD_LOGIC;  
			  clear : in std_logic;
           frequency  : out unsigned (N-1 downto 0);
			  interrupt : out std_logic
			  
      );
end component;

signal cnten, power_gating : std_logic; 
signal frequency_buff : unsigned(15 downto 0); 
signal interrupt_buff : std_logic;

begin

rtc: RTC_1M port map (clk => clk, arstn => arstn, period => measure_period(5 downto 0), data_valid => valid_data, powergating=> power_gating, cnt_en=>cnten, output_sec => output_sec, output_min => output_min);

extratimer: input_capture_timer port map (clk => clk , enable => cnten, arstn => arstn, analog_in => analog_in, clear => power_gating, interrupt => interrupt_buff,  frequency=> frequency_buff );
load <= not(power_gating);
powergating <= power_gating;
frequency <= frequency_buff; 
interrupt <= interrupt_buff;
end architecture; 

