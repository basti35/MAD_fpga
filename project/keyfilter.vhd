--**********************************************************************************
--File name Keyfilter

--version: 13/06/2013

--This block allows to have only a spike in the signal refer to a key pressed instead
--of a step prolonged in time. 
--**********************************************************************************

-- Declaration of libraries
library ieee;

use ieee.std_logic_1164.all; --Allows to use enhanced signal types 
							 --like std_standard_logic	

entity Keyfilter is

 --Declaration of inputs and outputs of the block
	port (	--input
		  
		  	x		:in std_logic;  --Signal of the key
		  	
		  	clk		:in std_logic;  --Main clock 
		  	
		  	--output
		  	y		:out std_logic	--Signal filtered of the key that go to other blocks
		  );
		  
end entity Keyfilter;

architecture main of Keyfilter is
   
   signal c1, c2 : std_logic :='0'; --Define 2 signal and initialise them to 0 

begin

process (clk) is --the process is sensible to the variation of clock

begin

	if (clk'event and clk='1') then --At every raisign edge of the clock 
	
		c2 <= c1; --Assign C1 to C2 and then x to C1, is a sequential block 
		c1 <= x;

	end if;

end process;

y <= c1 and (not c2); --When C1=1 and C2=0 then y=1 otherwise is always y=0. In this way we have only a spike of y, in fact at the next raising edge of the clock, if the key is yet pressed, C2=C2=1 so y=0.

end architecture main;