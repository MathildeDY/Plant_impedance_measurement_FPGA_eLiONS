library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- multiplexer 2-to-1
entity mux2to1_8bit is
    Port ( 
        -- input channels 
        in0 : in std_logic_vector(7 downto 0);
        in1 : in std_logic_vector(7 downto 0);
        -- Selector 
        sel : in std_logic_vector (0 downto 0);
        -- output (8 bit)
        data_to_master : out std_logic_vector(7 downto 0)
    );
end mux2to1_8bit;

architecture Behavioral of mux2to1_8bit is
begin
   
    process(sel, in0, in1)
    begin
        case sel is
            when "0" =>  
                data_to_master <= in0;
            when "1" =>  
                data_to_master <= in1;
            when others =>  -- security condition
                data_to_master <= (others => '0');
        end case;
    end process;
end Behavioral;
