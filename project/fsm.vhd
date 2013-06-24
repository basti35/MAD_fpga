--******************************************************************************
--File name: FSM

--Version: 7/06/2013

--Finit State Machine of the system. 
--*****************************************************************************
-- Declaration of libraries 
library IEEE;

use ieee.std_logic_1164.all;		--Allows to use enhanced signal types like std_standard_logic	

use ieee.std_logic_arith.all;		--Allows to use arithmetic functions that operate on signal types std_logic_vector and std_logic_vector

use ieee.std_logic_unsigned.all;	--Provides unsigned numerical computation on type std_logic_vector

entity FSM is

 --Declaration of inputs and outputs of the block

 port (   	--input 
          	 clk          :in std_logic; --Main clock
          	 
          	 level_OK     :in std_logic; --Signal that indicate to the STATE block if levels of tanks are ok or not
			 -- 0: levels of tanks ok
			 -- 1: levels of tanks not ok
          	
          	 end_receipt  :in std_logic; --Signal that indicate to the STATE block that the PICs have ended to erogate the receipt
          	 			 
			 n_enter      :in std_logic; --Signal that become equal to 1 when key enter is pressed.
			 
			 n_reset      :in std_logic; --Reset signal, is low active
			 
			 error		  :in std_logic; --Error signal
			 		 
			 --output
			 
			 led_on		:out std_logic;--Signal that activate a led to indicate that FSM is working
			 
			 code         :out std_logic_vector(7 downto 0);  --Vector that indicate to LCD block which message has to print
			 
			 en_serial    :out std_logic;--Signal that activate transmission of UART block
			 
			 en_mux       :out std_logic;--Signal that key which input of MUX is take to output
			 
			 en_counter   :out std_logic --Signal that activate the COUNTER block
			 
			 );
			 			 
end entity;

architecture main of FSM is

--Declaration of variables
		
		type state is(
			START,--in this state we say welcome to user
							
			DELAY,--State where the FSM stays in present_state until the end of count. Allows to print a message on LCD for a certain time
							
			CHECK_LEVELS,--State where FSM receive trough UART the state of tanks levels and print on LCD messages that alert user if levels are ok or not
										    
			CHECK_GLASS,--State where the FSM stay until the user confirm the present of the glass under the machine 
							
			IDLE,--In this state FSM activate the COUNTER block that print on LCD the name of cocktails. When the key enter is pressed activate the transmission of the receipt on UART  
								 
			EROGATION,--FSM remains in this state until the message of end receipt is recieved from PIC on UART.Otherwise, if there are any error, after 15 seconds FSM return to START state.
									  						
			TAKE_GLASS);--In this state a message of end receipt is printed on LCD
		
		signal next_state: state;--Signal where is indicated the future state of FSM
		
		signal present_state: state;--Signal where is indicated the present state of FSM
		
		constant max_delay: natural:=65535;--For change max value of count signals CHANGE here 
		
		signal delay_count: natural range 0 to max_delay; --Signals used to make delay
		
		signal delay_count2:natural range 0 to max_delay; 
		
		signal delay_init:  natural range 0 to max_delay; 
 
 begin
  
  first:process(clk)--the process is sensible to the variation of signal clock
  begin
        if (clk'event and clk='1') then --at every rising edge of the clock
             
             if n_reset='1' then --if reset is enabled
                
                present_state<=START; --Return to state SART
                
                next_state<=CHECK_LEVELS;--Next state will be CHECK_LEVELS
                
                --Disable all outputs
                en_serial <='0'; 
                en_mux <= '1';
                code<="00000000"; --this message is not print because mux is disabled. Since also COUNTER is disabled nothing will be print on LCD
                led_on<='0';
                en_counter<='0';
        
             else
                led_on<='1';--Turn on the operating led 
                
                case present_state is --On the base of the value of present_state signa FSM doing actions
                
                    when START => --Sate START
                     
                            en_serial <='0'; --Nothing is transimtted to PIC
                            
                            en_mux <= '0'; --Print on LCD the message indicated by FSM
                
                            code<="00001011";--Print welcome message on LCD (message 11)
                
                            en_counter<='0';--COUNTER block disabled
                            
                            present_state<=DELAY;--to take the message printed on lcd for 4 seconds we set the delay state in order to make a count that takes about 4 seconds to end
                                                
                            delay_count<=50000;
                            delay_count2<=4000;--set this value to change the duration of delay. 1000=1second delay
                            delay_init<=50000;
                            
                            next_state<=CHECK_LEVELS; --After the delay go to check_levels
                            
                    when DELAY =>
        
                            if (delay_count=0) then --we have this condition only every delay_count cycles 
                                
                                delay_count<=delay_init;--reinitialize delay_count
                                
                                delay_count2<=delay_count2-1; --decrement delay_count2
                            else
                                delay_count<=delay_count-1; --decrement delay_count
                            end if;
                            
                            if (delay_count2=0) then --when delay_count2 is equal to zero then go to next state
                                present_state<=next_state;
                            end if;
                    
                    when CHECK_LEVELS =>
                            
                            if (level_OK='0') then --Tanks levels are ok
                            
                                en_serial <='0'; --Nothing is transimtted to PIC
                                
                                en_mux <= '0';--Print on LCD the message indicated by FSM
                                
                                code<="00001100";--Message of livels ok on lcd (message 12) 
                                
                                en_counter<='0';--COUNTER block disabled
                                
                                present_state<= DELAY; --In order to take the message on LCD for 3 seconds
                                
                                delay_count<=50000;
                                delay_count2<=3000;--delay of 3 seconds
                                delay_init<=50000;
                                
                                next_state<= CHECK_GLASS;
                                
                            else --Tanks levels are not ok
                            
                                en_serial <='0'; --Nothing is transimtted to PIC
                                
                                en_mux <= '0';--Print on LCD the message indicated by FSM

                                code<="00001101";--message of livels NOT OK on lcd (message 13)

                                en_counter<='0'; --COUNTER block disabled
                                                      
                                present_state<= CHECK_LEVELS; --We remain in this state until levels returns ok
                                
                                next_state<= CHECK_GLASS;            
                            end if;
                            
                    when CHECK_GLASS =>

                                en_serial <='0'; --Nothing is transimtted to PIC
                                
                                en_mux <= '0'; --Print on LCD the message indicated by FSM

                                code<="00010000";--Message control glass (message 16)

                                en_counter<='0';--Enable the COUNTER block in order to print on LCD the message indicated by COUNTER
                                
                                present_state<= CHECK_GLASS; --We remain in this state until user press enter indicating that the glass is present

                                next_state<= IDLE;
                                
                                if (n_enter='1') then --when key enter is pressed present state become IDLE
                                        present_state<= IDLE;
                                        next_state<= EROGATION;
                                end if;
                                
                            
                    when IDLE =>
                            
                                en_serial <='0'; --Nothing is transimtted to PIC
                                
                                en_mux <= '1';--Print on LCD the message indicated by counter
                        
                                code<="00000000";  
                                
                                en_counter<='1';--Enable the COUNTER block in order 
                                                --to print on LCD the message indicated 
                                                --by COUNTER
                                
                                present_state<= IDLE; --We stay in this state until the enter key is pressed so user has selected a cocktail
                                
                                next_state<= EROGATION;
                                
                                if (n_enter='1') then --When enter key is pressed
                                 
                                        en_serial <='1'; --enable trasmission on UART of the receipt indicated by COUNTER block 
                                        
                                        present_state<= EROGATION;
                                        
                                        next_state<= TAKE_GLASS;
                                        
                                        --Set counter variables for time-out in EROGATION
                                        delay_count<=50000;
                                        delay_count2<=20000; --delay of 20 seconds
                                        delay_init<=50000;
                                end if;
                    
                    when EROGATION =>
                    
                                en_serial <='0'; --Nothing is transmitted to PIC
                                
                                en_mux <= '0';--Print on LCD the message indicated by FSM
                                
                                code<="00001110"; --Message of wait (message 14)
                                                      
                                en_counter<='0';--COUNTER block disabled
                                
                                present_state<= EROGATION; --We remain in this state until signal of end_receipt is high namely when the message of end receipt is received on UART
                                
                                next_state<= TAKE_GLASS;
                                
                                if (end_receipt='1') then--Message of end receipt received
                                    
                                        present_state<= TAKE_GLASS;
                                        
                                        next_state<= CHECK_LEVELS;
                                
                                end if;
                                
                                --simultaneously a counter of 20 seconds is activated. If the end receipt message is not received during this period an error as occurred and  the state of FSM return in start after print on LCD an error message
                                
                                --delay
                                if (delay_count=0) then
                                    delay_count<=delay_init;
                                    delay_count2<=delay_count2-1;
                                else
                                    delay_count<=delay_count-1;
                                end if;
                            
                                if (delay_count2=0) then
                                
                                    code<="00000000";--Error message (message 0)
                                      
                                    --set DELAY state 
                                    delay_count<=50000;
                                    delay_count2<=3000;--delay of 3 seconds
                                    delay_init<=50000;
                                    
                                    present_state<=DELAY;
                                    
                                    next_state<=START;
                                
                                end if;
                                
                                --Error
                                    
                                if (error='1') then --If there is an error in communication go to time-out error
                                    
                                    delay_count<=3; --no zero
                                        
                                    delay_count <=0; --at the next rising edge of the clock go to time-out error 
                                
                                end if;
                                
                    when TAKE_GLASS =>
                    
                                en_serial <='0'; --Nothing is transimtted to PIC
                                
                                en_mux <= '0';--Print on LCD the message indicated by FSM
                                
                                code<="00001111";--Take glass message (message 15) 
                                
                                en_counter<='0';--COUNTER block disabled
                    
                                --set DELAY state
                                delay_count<=50000;
                                delay_count2<=4000;--delay of 4 seconds
                                delay_init<=50000;
                                
                                present_state<= DELAY; 
                                
                                next_state<= CHECK_LEVELS;
                    
                    end case;
                end if; --reset
        end if; --synchronism
  end process first;
 end architecture;