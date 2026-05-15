LIBRARY ieee; 
use ieee.std_logic_1164.all; 
 
entity seven_segment_display is  

port ( 
SW : in std_logic_vector (3 downto 0); 
HEX0 : out std_logic_vector (0 to 6) 
); 

end seven_segment_display; 
 
architecture beh of seven_segment_display is
  
begin 

HEX0(0)<= (not(SW(3)) and not(SW(2)) and not(SW(1)) and SW(0)) or (not(SW(3)) and SW(2) and 
not(SW(1)) and not(SW(0))) or (SW(3) and SW(2) and not(SW(1)) and SW(0)) or (SW(3) and not(SW(2)) and 
SW(1) and SW(0));

HEX0(1)<= (SW(3) and SW(1) and SW(0)) or (SW(2) and SW(1) and not(SW(0))) or (SW(3) and SW(2) and 
not(SW(0))) or (not(SW(3)) and SW(2) and not(SW(1)) and SW(0)); 

HEX0(2)<= (SW(3) and SW(2) and SW(1)) or (not(SW(3)) and not(SW(2)) and SW(1) and not(SW(0))) 
or(SW(3) and SW(2) and not(SW(0))); 

HEX0(3)<= (SW(2) and SW(1) and SW(0)) or (not(SW(3)) and not(SW(2)) and not(SW(1)) and SW(0)) or 
(not(SW(3)) and SW(2) and not(SW(1)) and not(SW(0))) or (SW(3) and not(SW(2)) and SW(1) and 
not(SW(0))); 

HEX0(4)<= (not(SW(3)) and SW(0)) or (not(SW(2)) and not(SW(1)) and SW(0)) or (not(SW(3)) and SW(2) and 
not(SW(1))) ; 

HEX0(5)<= (not(SW(3)) and SW(1) and SW(0)) or (not(SW(3)) and not(SW(2)) and SW(0)) or (not(SW(3)) and 
not(SW(2)) and SW(1)) or (SW(3) and SW(2) and not(SW(1)) and SW(0)); 

HEX0(6)<= (not(SW(3)) and not(SW(2)) and not(SW(1))) or (not(SW(3)) and SW(2) and SW(1) and SW(0)) or 
(SW(3) and SW(2) and not(SW(1)) and not(SW(0)));  

end beh;
