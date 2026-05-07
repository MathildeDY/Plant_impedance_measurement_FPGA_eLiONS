library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity input_capture_timer is 

generic (
	   N : integer  := 16  -- Timer parallelism     
        );

port (     clk     : in  STD_LOGIC;    
	        enable     : in  STD_LOGIC;          
           arstn   : in  STD_LOGIC;           
           analog_in : in  STD_LOGIC;  
			  clear : in std_logic;
			  interrupt : out std_logic;
           frequency  : out unsigned (N-1 downto 0)  
      );



end input_capture_timer; 




architecture beh of input_capture_timer is 



signal counter, acquisition_1, acquisition_2, ticks : unsigned (N-1 downto 0);
signal prev_signal : std_logic;
signal max : unsigned (N-1 downto 0) := (others => '1'); 
signal min : unsigned (N-1 downto 0) := (others => '0');
--signal fclk : unsigned(N-1 downto 0) := to_unsigned(1171875, N);
begin

process(clk, arstn)
    begin
        if (arstn = '0') then				--reset condition, everything at zero
            counter  <= (others=> '0');
	    prev_signal <= '0'; 
	    acquisition_1 <= (others=> '0');
	    acquisition_2 <= (others=> '0');
				frequency <= (others=> '0');
				interrupt <= '0';

        elsif (clk'event and clk = '1') then             -- at each clock rising edge
	
		if (enable = '1') then			-- if enable is active
			counter <= counter + 1;  	-- the timer counts
		
		
 
			if (prev_signal = not(analog_in) and analog_in = '0') then   --  if there is a falling edge..
				acquisition_1 <= acquisition_2;                      -- we capture the two acquisitions ..
				acquisition_2 <= counter; 
			end if ; 
			prev_signal <= analog_in; 
		

			if (acquisition_1 /= min and acquisition_2 /= min) then      -- if we filled both the acquisitions, we can compute 				if (acquisition_2 > acquisition_1 ) then -- no overflow
					ticks <= acquisition_2 - acquisition_1;
					frequency <= ticks; --fclk / ticks;
					interrupt <= '1';

				elsif (acquisition_2 < acquisition_1) then -- with overflow
					ticks <= acquisition_2 + max - acquisition_1;
					frequency <= ticks; --fclk / ticks;
					interrupt <= '1';
			end if;
		elsif (enable = '0' and clear = '1' ) then
	    counter  <= (others=> '0');
	    prev_signal <= '0'; 
	    acquisition_1 <= (others=> '0');
	    acquisition_2 <= (others=> '0');
       frequency <= (others=> '0'); 
		 interrupt <= '0';
		end if; 
		
		
		        
        end if;
	
    end process; 

end beh;
