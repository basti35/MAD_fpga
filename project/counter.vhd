--**********************************************************************************
--File Name: Counter

--Version: 7/06/2013

--This block when 'up' or 'down' are high, move a counter associated to a identificative code which is put in output 
--**********************************************************************************

--Declaration of libraries
library IEEE;

use ieee.std_logic_1164.all;		--Allows to use enhanced signal types like std_standard_logic   

use ieee.std_logic_arith.all;		--Allows to use arithmetic functions that operate on signal types std_logic_vector and std_logic_vector

use ieee.std_logic_unsigned.all;	--Provides unsigned numerical computation on type std_logic_vector

use ieee.numeric_std.all;			--Provides numerical computation types defined include: unsigned  signed  arrays of type std_logic for signals

entity counter is

 --Declaration of inputs and outputs of the block

 port (
 	   --input 
       clk		:in std_logic; --main clock
       en		:in std_logic; --enable
	   up		:in std_logic; --command UP
	   down		:in std_logic; --command DOWN
			 
	   --output
	   code		:out std_logic_vector(7 downto 0)); --Code that indicate a cocktail
			
end entity;

architecture main of counter is
		
		--Declaration of variables
		
		signal counter: integer range 1 to 10;
				
 begin
  
  process(clk, en)
  
  begin
	if(clk'event and clk='1') then
	
		if(en='1') then
		
			if (down='1') then --DOWN high 
			
				if(counter=1) then --if down is high when counter is =1 we set it to 10
				
					counter<=10;
					
				else
					
					counter<=counter-1;
				end if;
					
			end if;
			
			if (up='1') then --UP high
				
				if (counter=10) then --if up is high when counter is =10 we set it to 1 
					
					counter<=1;
				else
						
					counter<=counter+1;
						
				end if;
					
			end if;
				
			code<=conv_std_logic_vector(counter,8); --conversion to std_logic_vector the integer counter
		
		end if;
		
	end if;
	
  end process;
 end main;