------------------------------------------------------------------------------------------
--File name: Decoder

--Version: 7/06/2013

-- This block take in input messages from UARTs' block and decode them in order to
-- have in output signals that enable or disable other blocks.
------------------------------------------------------------------------------------------

-- Declaration of libraries 
library IEEE;
use ieee.std_logic_1164.all;		--Allows to use enhanced signal types 
									--like std_standard_logic	

use ieee.std_logic_arith.all; 		--Allows to use arithmetic functions that operate 
									--on signal types std_logic_vector 
									--and std_logic_vector

use ieee.std_logic_unsigned.all; 	--Provides unsigned numerical computation
  									--on type std_logic_vector


use ieee.numeric_std.all; 			--Provides numerical computation types 
									--defined include: unsigned  signed  arrays of 
									--type std_logic for signals

entity Decoder is

 --Declaration of inputs and outputs of the block
  
 port (   --input 
          --main clock is not explicit
          	 msg			:in std_logic_vector(7 downto 0); --this is the vector of 
          	 										--data which come form USART
          	 
          --output

			 led0			:out std_logic; --Signal that turn on or off led relative 
			 								--to the tank 1

			 led1			:out std_logic; --Signal that turn on or off led relative 
			 								--to the tank 2

			 led3			:out std_logic; --Signal that turn on or off led relative 
			 								--to the tank 3

			 led2			:out std_logic; --Signal that turn on or off led relative 
			 								--to the tank 4

			 receipt		:out std_logic; --Signal that advise the STATE block that
			 								--the PICs have ended to erogate the receipt

			 levels			:out std_logic; --Signal that advise the STATE block if 
			 								--levels of tanks are ok or not
			 								
			 error			:out std_logic
		);
		 
end entity;

architecture main of Decoder is
		
 begin
  
  process(msg)	--the process is sensible to the variation of signal msg
   begin
	
		if (msg="11110000") then --'11110000': this message means that
			 					 --the PICs have ended to erogate the receipt
			
			receipt<='1';  --Say to the STATE block that the receipt is ended 
			
			levels<='0';   --Is not important whit this message. We take it equal 
						   --to 1 that means levels ok
			
			led0<='0';     --Take off the leds relative to  low levels of tanks  
			led1<='0';     
			led2<='0';
			led3<='0';
		
			error<='0'; --No error has occurred
			
		elsif (msg="00000000") then  --'00000000': this message means that levels of 
									 --tanks are ok  
		
				receipt<='0';    	 --With this message we want only to indicate that
									 --levels are ok, not that receipt is finished
							
				levels<='0';         --Say to the STATE block that levels of tanks
									 --are ok
				
				led0<='0';           --take all led off
				led1<='0';
				led2<='0';
				led3<='0';
				
				error<='0'; --No error has occurred
								
		elsif (msg="01000101") then --='E' If message is 'E' PIC Master says to the FPGA
									--that there where an error in the communication of
									--the receipt
				
				receipt<='0';    	 --With this message we want only to indicate that
									 --levels are ok, not that receipt is finished
							
				levels<='0';         --Say to the STATE block that levels of tanks
									 --are ok
				
				led0<='0';           --take all led off
				led1<='0';
				led2<='0';
				led3<='0';
				
				error<='1'; --Error has occurred
				  	  
			  else 
			  	--In this else we consider that first 4 bits of the message which could
			  	--be 0 if level of the relative tank is ok or 1 if level is low. 
			  	
			  	levels<='1';  --Say to the STATE block that levels are not ok
			  	
				receipt<='0'; --Is not important with this message
				
			  	--In the following lines we make sure that 
			  	--the LEDs are linked to first 4 bits of message. 
									      			
				led0<=msg(0); --bit 0 refers to the state of the float of tank 1 
				led1<=msg(1); --bit 1 refers to the state of the float of tank 2
				led2<=msg(2); --bit 2 refers to the state of the float of tank 3
				led3<=msg(3); --bit 3 refers to the state of the float of tank 4
				
				error<='0'; --No error has occurred
				
		 end if;		
  
 end process;
end architecture;