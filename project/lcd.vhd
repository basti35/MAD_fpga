--**********************************************************************************
--File name: LCD

--version: 7/06/2013

--This block control the LCD and permits to print on it different messages
--**********************************************************************************

--Declaration of libraries
library IEEE;

use ieee.std_logic_1164.all;        --Allows to use enhanced signal types like std_standard_logic   

use IEEE.STD_LOGIC_ARITH.ALL;       --Allows to use arithmetic functions that operate on signal types std_logic_vector and std_logic_vector

use IEEE.STD_LOGIC_UNSIGNED.ALL;    --Provides unsigned numerical computation on type std_logic_vector

use ieee.numeric_std.ALL;           --Provides numerical computation types defined include: unsigned  signed  arrays of type std_logic for signals

entity LCD is

  --Declaration of inputs and outputs of the block

  port(
      --input
      clock_50MHz   :in std_logic;
      spike_50kHz   :in std_logic;

      reset         :in std_logic;
              
      message       :in std_logic_vector(7 downto 0); --input vector, indicate the message that has to be print on LCD.
                                                      --It could indicate 255 messages, we have only 17 messages
                                                    
      --output
      
      --This signals are used to put in operation the display
      
      lcd_rs        :out std_logic;  --rs: register select=>1 
        
      lcd_en        :out std_logic;
      lcd_rw        :out std_logic;
      lcd_on        :out std_logic;
      lcd_blon      :out std_logic;

      --inout
      lcd_data      :inout std_logic_vector(7 downto 0));

end entity LCD;

architecture main of LCD is
  
--Declaration of variables
  
  type state is (
    			INIT1, INIT2, INIT3, DELAY, WAIT_BF, FUNC_SET, DISPLAY_OFF, DISPLAY_CLEAR, 
    			DISPLAY_ON, MODE_SET, PRINT_STRING_SOLID,RETURN_HOME, LINE2
    			);
  
  signal lcd_fsm: state;--This is the current state of the state machine
  
  signal next_state: state;--This is the state that will occur after the delay

  --delay to next action counter
  constant max_delay: natural :=65535;
  signal delay_count: natural range 0 to max_delay;

  --All the messages that the block has memorized are inserted in an array of 
  --std_logic_vector.
  --Now we have 17 messages. If an addition or a cancellation of a string is request
  --there is to change the dimension of Tipe_Array and add or delete an element in
  --chars_string_display. Messages has to be written in Hexadecimal code.
  type Tipe_Array is array (0 to 16) of std_logic_vector(0 to 255); 
  signal chars_string_display : Tipe_Array :=(
                    X"20202020204552524F522020202020202020202054494D452D4F555420202020", 
                    --mex 0 ERROR/TIME-OUT
                                              
                    X"202053656C2E436F636B7461696C202D312D566F646B612053686F742020202B", 
                    --mex 1 Sel.Cocktail -/1-Vodka Shot +
                    
                    X"202053656C2E436F636B7461696C202D322D566F646B61204F72616E6765202B", 
                    --mex 2 Sel.Cocktail -/2-Vodka Orange +
                                              
                    X"202053656C2E436F636B7461696C202D332D566F646B61204C656D6F6E20202B", 
                    --mex 3 Sel.Cocktail -/3-Vodka Lemon +
                    
                    X"202053656C2E436F636B7461696C202D342D506573717569746F20202020202B", 
                    --mex 4 Sel.Cocktail -/4-Pesquito +
                    
                    X"202053656C2E436F636B7461696C202D352D566F646B6120506561636820202B", 
                    --mex 5 Sel.Cocktail -/5-Vodka Peach +
                    
                    X"202053656C2E436F636B7461696C202D362D4F72616E6765202020202020202B", 
                    --mex 6 Sel.Cocktail -/6-Orange +
                                              
                    X"202053656C2E436F636B7461696C202D372D5365784F6E54686542656163682B", 
                    --mex 7 Sel.Cocktail -/7-SexOnTheBeach +
                    
                    X"202053656C2E436F636B7461696C202D382D4C656D6F6E61646520202020202B", 
                    --mex 8 Sel.Cocktail -/8-Lemonade +
                    
                    X"202053656C2E436F636B7461696C202D392D4D69782026204472696E6B20202B", 
                    --mex 9 Sel.Cocktail -/9-Mix & Drink +
                    
                    X"202053656C2E436F636B7461696C202D31302D4D6F73636F772020202020202B", 
                    --mex 10 Sel.Cocktail -/10-Moscow +
                    
                    X"2020202057454C434F4D45212020202020204D69782026204472696E6B202020", 
                    --mex 11 Welcome! / Mix & Drink
                    
                    X"2054616E6B7327204C6576656C732020202020202020204F4B20202020202020", 
                    --mex 12 Tank's Levels / Ok
                    
                    X"2054616E6B7327204C6576656C7320202020202020526566696C6C2020202020", 
                    --mex 13 Tank's Levels / Refill
                    
                    X"204472696E6B204F722044726976652020202020202020202020202020202020", 
                    --mex 14 Drink or Drive
                    
                    X"20202054616B6520476C61737320202020202020202020202020202020202020", 
                    --mex 15 Take Glass
                    
                    X"506C61636520596F757220476C6173732020507265737320456E746572202020"  
                    --mex 16  Place Your Glass/Press Enter
                    
                                             );
    
  
  --pointer to current char inside the string
  signal char_pointer: natural range 0 to 31;
  --signal char_rotate_count: natural range 0 to 31;
  signal char_position: natural range 0 to 7;
  
  --starting index of string (for ROTATE mode)
  signal string_seed: natural range 0 to 15;

  --internal signal for lcd read/write (needed to command
  --three-state buffer).
  -- lcd_rw_int = H: ask for reading
  -- lcd_rw_int = L: ask for writing
  signal lcd_rw_int: std_logic;
  signal lcd_data_int: std_logic_vector(7 downto 0);

begin

  --lcd power on
  lcd_on <= '1';
  
-- Bidirectional tri-state LCD data bus
    lcd_data <= lcd_data_int when lcd_rw_int = '0' else "ZZZZZZZZ";  
    lcd_rw <= lcd_rw_int;
  
  lcd_controller: process(clock_50MHz, reset)
  begin
    if reset='0' then
      --do the same as INIT1
      lcd_fsm <= INIT1;
      next_state <= INIT2;

      -- from datasheet
      lcd_data_int <= X"38"; 
     
      lcd_en <= '1';
      lcd_rs <= '0';
      lcd_rw_int <= '1';

    elsif (clock_50MHz'event and clock_50MHz='1') then
      if(spike_50kHz='1') then
        case lcd_fsm is

          when DELAY =>
            -- variable time width delay state
            -- stay locked here with lcd_enable LOW for (delay_count*20us)
                                
            lcd_en <= '0';
            if (delay_count=0) then
              lcd_fsm <= next_state;
            else
              delay_count <= delay_count-1;
            end if;
                            
          when WAIT_BF =>
              delay_count <= 500;
              lcd_fsm <= DELAY;
                              
          when INIT1 =>
            --first transmission (see datasheet)
            --after this transm is needed to wait for more than 4.1 ms

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";

            -- the state we want to enter after delay
            next_state <= INIT2;
            
        --delay count <= 210 (20us * 210 = 4,2 ms) 

            lcd_fsm <= DELAY;
            char_pointer <= 0;
            string_seed <= 0;

          when INIT2 =>
            --second transmission (see datasheet)
            --after this transm is needed to wait for more than 100us

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            next_state <= INIT3;
            lcd_fsm <= DELAY;
            delay_count <= 6; --6 count @50kHz = 20us * 6 = 120us
            char_pointer <= 0;
            string_seed <= 0;
                
          when INIT3 =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            next_state <= FUNC_SET;
            lcd_fsm <= WAIT_BF;
            char_pointer <= 0;
            string_seed <= 0;
                
          when FUNC_SET =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_OFF;
              
          when DISPLAY_OFF =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"08";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_CLEAR;
                
          when DISPLAY_CLEAR =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"01";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_ON;

            when DISPLAY_ON =>
            
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"0C";
            lcd_fsm <= WAIT_BF;
            next_state <= MODE_SET;

          when MODE_SET =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"06";
            lcd_fsm <= WAIT_BF;
            next_state <= PRINT_STRING_SOLID;

          when PRINT_STRING_SOLID =>

            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';

            for char_position in 0 to 7 loop
              lcd_data_int(char_position) <= chars_string_display(conv_integer(message))(char_pointer*8+7-char_position);
              --(conv_integer(message)) indicate which element of the array we want print
              --message is converted in integer from std_logic_vector
              
              --(char_pointer*8+7-char_position) permits to print every single character
              --of the indicated string
            end loop;
            
            char_pointer <= char_pointer + 1;            
            --if both the two lines are completed
            if (char_pointer = 31) then
              next_state <= RETURN_HOME;
            --elsif the first line is completed  
            elsif(char_pointer = 15) then
              next_state <= LINE2;
            end if;
            lcd_fsm <= WAIT_BF;
                
          when LINE2 =>
            
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"C0";
            lcd_fsm <= WAIT_BF;
            next_state <= PRINT_STRING_SOLID;

          when RETURN_HOME =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"80";
            lcd_fsm <= WAIT_BF;
            char_pointer <= 0;
            next_state <= PRINT_STRING_SOLID;
                
        end case;
        --case(lcd_fsm)

      end if;
      --if(spike_50kHz)

    end if;
    --if(reset)

  end process lcd_controller;

end architecture;