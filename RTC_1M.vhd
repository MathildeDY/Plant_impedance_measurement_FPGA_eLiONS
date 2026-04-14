

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
	output_sec : out std_logic_vector (11 downto 0)
    );
end RTC_1M;

architecture beh of RTC_1M is 

signal pulses : unsigned  (31 downto 0) := (others => '0');
signal wake_time : unsigned (31 downto 0);


begin 


process(arstn, clk)
    begin
        if arstn = '0'then
            pulses <= (others => '0');
	    powergating <='0';
	    cnt_en <= '0';
        elsif (rising_edge(clk))  then
				--if (pulses = "00000000010110111000110110000000" )then  --6 sec
		      if (pulses = wake_time)then  --6 sec
			 pulses <= pulses + 1;
			 powergating <= '1';
			  cnt_en <= '0';
		      --elsif (pulses = "00000000010111010001010000100000") then --6.1 sec
				elsif (pulses = (wake_time + to_unsigned(100000,32)) ) then --6.1 sec
			 pulses <= pulses + 1;
			 powergating <= '1';
			 cnt_en <= '1';
		      --elsif (pulses = "00000000011011000101011001100000") then --7.1 sec
				elsif (pulses > (wake_time + to_unsigned(1100000,32)) ) then --7.1 sec
			 pulses <= (others => '0');
			 powergating <= '0';
			 cnt_en <= '0';
		      else                                                   --just count and no changes in the control signals
			pulses <= pulses + 1;	
		       end if;    	       
        end if;
    end process;

 -- Time to wake
wake_time <= resize(unsigned(SW) * to_unsigned(1000000,20) ,32);
output_sec <= std_logic_vector(pulses(31 downto 20));

end architecture; 