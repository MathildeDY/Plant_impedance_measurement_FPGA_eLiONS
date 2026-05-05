library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Agrichip1_TX is 

port(

	bytes : in std_logic_vector (15 downto 0);
	clk, arstn : in std_logic;
	--wr_en      : in std_logic;
	scl              : inout std_logic;
    	sda              : inout std_logic
);

end Agrichip1_TX ;


architecture beh of Agrichip1_TX is 

component my_slave is 
generic (
    MINION_ADDR          : std_logic_vector(6 downto 0)  := "0000011"; 
	 
    -- noisy SCL/SDA lines can confuse the minion
    -- use low-pass filter to smooth the signal
    -- (this might not be necessary!)
    USE_INPUT_DEBOUNCING   : boolean := false;
    -- play with different number of wait cycles
    -- larger wait cycles increase the resource usage
    DEBOUNCING_WAIT_CYCLES : integer := 4);
  port (
    scl              : inout std_logic;
    sda              : inout std_logic;
    clk              : in    std_logic;
    arstn            : in    std_logic;
   -- wr_en            : in      std_logic;
    data_to_master   : in    std_logic_vector(15 downto 0) );
    --byte_count : out std_logic_vector (0 downto 0) ); --my add, in order to select from the mux outside the right part of the 2 byte stem frequency's string
end component; 


--component mux2to1_8bit is
--    Port ( 
--        -- input channels 
--        in0 : in std_logic_vector(7 downto 0);
--        in1 : in std_logic_vector(7 downto 0);
--        -- Selector 
--        sel : in std_logic_vector (0 downto 0);
--        -- output (8 bit)
--        data_to_master : out std_logic_vector(7 downto 0)
--    );
--end component; 

signal sel : std_logic_vector (0 downto 0);

begin

--mx: mux2to1_8bit port map (in0=> byte0, in1=>byte1, sel=>sel, data_to_master=>data_to_master );
minion: my_slave port map (scl=>scl, sda=>sda, clk=> clk, arstn=>arstn, data_to_master=> bytes);-- wr_en => wr_en

end beh;
