--**********************************************************************************
--File name: Mux

--Version: 13/06/2013

--We use this combinatory block to decide if the STATE or COUNTER blocks have to indicate
--a message to write on LCD screen and to send with UART
--**********************************************************************************

-- Declaration of libraries 
library IEEE;

use ieee.std_logic_1164.all;	--Allows to use enhanced signal types 
								--like std_standard_logic	

entity Mux is

 --Declaration of inputs and outputs of the block

 port (   --input 
         
          en	:in std_logic; --enable signal
		  
		  in1	:in std_logic_vector(7 downto 0); 	--Input1 linked to COUNTER block
		  
		  in2	:in std_logic_vector(7 downto 0); 	--Input2 linked to STATE block
		
		  --output
		
		  out1	:out std_logic_vector(7 downto 0)); --Output linked to LCD screen and to TX_data pin of UART block
			
end entity;

architecture main of Mux is

 begin
  
  process(en) --the process is sensible to the variation of signal msg

  begin

			if (en='1') then
			
				out1<=in1;	--if enable is high COUNTER block send data to out (LCD and UART)
			
			else 
				
				out1<=in2;	--if enable is low STATE block send dat to out (LCD and UART)
			
			end if;

end process;

end main;