library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity LCD is  
  port(
    --input
      clock_50MHz:  in std_logic;
      spike_50kHz:  in std_logic;

      reset:  in std_logic;
      mode:   in std_logic_vector(1 downto 0);
        --mode: 00:SOLID
        --      01:ROTATING
        --      10:BLINKING

      --chars_string_display:  in std_logic_vector (0 to 255);
        --string to be visualized

    --output
      lcd_rs:   out std_logic;
        --r
      lcd_en:   out std_logic;
      lcd_rw:   out std_logic;
      lcd_on:   out std_logic;
      lcd_blon: out std_logic;
		debug:	 out std_logic_vector(17 downto 0);

    --inout
      lcd_data: inout std_logic_vector(7 downto 0));

end entity;

architecture main of LCD is
  type state is (
    INIT1, INIT2, INIT3, DELAY, WAIT_BF, --WAIT_BF_2,
    FUNC_SET, DISPLAY_OFF, DISPLAY_CLEAR, DISPLAY_ON, MODE_SET, PRINT_STRING_SOLID,
    PRINT_STRING_BLINK, PRINT_STRING_ROTATE, RETURN_HOME, LINE2, DISPLAY_OFF_BLINK,
	 DISPLAY_ON_WRITING, DISPLAY_CLEAR_WRITING);
  
  --this is the current state of the state machine
  signal lcd_fsm: state;
  --this is the state that will occur after the delay
  signal next_state: state;

  -- delay to next action counter
  constant max_delay: natural :=65535;
  signal delay_count: natural range 0 to max_delay;

  --pointer to current char inside the string
  signal char_pointer: natural range 0 to 31;
  --signal char_rotate_count: natural range 0 to 31;
  signal char_position: natural range 0 to 7;
  signal chars_string_display:  std_logic_vector (0 to 255) := X"6162636465666768697061626364656667686970616263646566676869706162";


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
  
  --lcd backlight on
  lcd_blon <= '1';


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
		debug <= (others => '0');

    elsif (clock_50MHz'event and clock_50MHz='1') then
      if(spike_50kHz='1') then
        case lcd_fsm is

          when DELAY =>
            -- variable time width delay state
            -- stay locked here with lcd_enable LOW for (delay_count*20us)
				
				debug(0) <= '1';
				
            lcd_en <= '0';
            if (delay_count=0) then
              lcd_fsm <= next_state;
            else
              delay_count <= delay_count-1;
            end if;
				
			
			when WAIT_BF =>
			  delay_count <= 500;
			  lcd_fsm <= DELAY;
			  
			  debug(1)<='1';
			  
--			when WAIT_BF_2 =>
--			  delay_count <= 100;
--
--			  lcd_fsm <= DELAY;

--          when WAIT_BF =>
--            -- ask for busy flag reading
--            lcd_en <= '1';
--            lcd_rs <= '0';
--            lcd_rw_int <= '1';
--            if(lcd_data(7) = '0') then
--              lcd_fsm <= next_state;
--            end if;
				
--				lcd_data_int <= "ZZZZZZZZ";
--            lcd_fsm <= WAIT_BF_2;
--
--          when WAIT_BF_2 =>
--            -- wait for busy flag to go down
--            lcd_en <= '1';
--            lcd_rs <= '0';
--            lcd_rw_int <= '1';
--            if(lcd_data(7) = '0') then
--              lcd_fsm <= next_state;
--            end if;

				
          when INIT1 =>
            --first transmission (see datasheet)
            --after this transm is needed to wait for more than 4.1 ms

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";

            -- the state we want to enter after delay
            next_state <= INIT2;

            lcd_fsm <= DELAY;
              --210 count @50kHz = 20us*210 = 4.2 ms
            char_pointer <= 0;
--            char_rotate_count <= 0;
            string_seed <= 0;

			   debug(2)<='1';

          when INIT2 =>
            --second transmission (see datasheet)
            --after this transm is needed to wait for more than 100us

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            next_state <= INIT3;
            lcd_fsm <= DELAY;
            delay_count <= 6;
              --6 count @50kHz = 20us * 6 = 120us
            char_pointer <= 0;
            --char_rotate_count <= 0;
            string_seed <= 0;
				
				debug(3)<='1';

          when INIT3 =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            next_state <= FUNC_SET;
            lcd_fsm <= WAIT_BF;
            char_pointer <= 0;
            --char_rotate_count <= 0;
            string_seed <= 0;

				debug(4)<='1';
				
          when FUNC_SET =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_OFF;

				debug(5)<='1';				

          when DISPLAY_OFF =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"08";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_CLEAR;

				debug(6)<='1';
				
          when DISPLAY_CLEAR =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"01";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_ON;

				debug(7)<='1';

			when DISPLAY_ON =>
            
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"0C";
            lcd_fsm <= WAIT_BF;
            next_state <= MODE_SET;
				
				debug(8)<='1';

          when MODE_SET =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"06";
            lcd_fsm <= WAIT_BF;
            case mode is
              when "00" =>
                next_state <= PRINT_STRING_SOLID;
              when "01" =>
                next_state <= PRINT_STRING_ROTATE;
              when "10" =>
                next_state <= PRINT_STRING_BLINK;
              when "11" =>
                next_state <= PRINT_STRING_SOLID;
            end case;
				
				debug(9)<='1';				

          when PRINT_STRING_SOLID =>

            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';

            for char_position in 0 to 7 loop
              lcd_data_int(char_position) <= chars_string_display(char_pointer*8+7-char_position);
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
				
				debug(10)<='1';								

          when PRINT_STRING_BLINK =>

            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';

            for char_position in 0 to 7 loop
              lcd_data_int(char_position) <= chars_string_display(char_pointer*8+7-char_position);
            end loop;

				char_pointer <= char_pointer + 1;            
            --if both the two lines are completed
            if (char_pointer = 31) then
              delay_count <= 16383;
              next_state <= RETURN_HOME;
              lcd_fsm <= DELAY;
            --elsif the first line is completed  
            elsif(char_pointer = 15) then
              next_state <= LINE2;
              lcd_fsm <= WAIT_BF;
            end if;
				
				debug(11)<='1';				

          when PRINT_STRING_ROTATE =>
          --strings need to be  32 chars long (NO EOF control)
            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';
				
            for char_position in 0 to 7 loop
				  if (char_pointer > 15) then --not yet increased
                --char_rotate_count <= 16 + ((string_seed + char_position) mod 16 );				  
					 --lcd_data_int(char_position) <= chars_string_display((char_rotate_count)*8+7-char_position);
					 lcd_data_int(char_position) <= chars_string_display((16 + ((string_seed + char_pointer) mod 16 ))*8+7-char_position);
              else
                --char_rotate_count <= ((string_seed + char_position) mod 16);  
					 --lcd_data_int(char_position) <= chars_string_display((char_rotate_count)*8+7-char_position);
					 lcd_data_int(char_position) <= chars_string_display((((string_seed + char_pointer) mod 16))*8+7-char_position);
				  end if;
            end loop;
            
				char_pointer <= char_pointer + 1;            				
            --if both the two lines are completed
            if (char_pointer = 31) then
              delay_count <= 16383;
              lcd_fsm <= DELAY;
              next_state <= RETURN_HOME;
              --string_seed <= ((string_seed + 1) mod 16);
            --elsif the first line is completed  
            elsif(char_pointer = 15) then
              next_state <= LINE2;
              lcd_fsm <= WAIT_BF;
            end if;

				debug(12)<='1';								

          when LINE2 =>
            
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"C0";
            lcd_fsm <= WAIT_BF;
            case mode is
              when "00" =>
                next_state <= PRINT_STRING_SOLID;
              when "01" =>
                next_state <= PRINT_STRING_ROTATE;
              when "10" =>
                next_state <= PRINT_STRING_BLINK;
				  when "11" =>
				    next_state	<= PRINT_STRING_SOLID;
            end case;

				debug(13)<='1';								

          when RETURN_HOME =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"80";
            lcd_fsm <= WAIT_BF;
    			char_pointer <= 0;
            case mode is
              when "00" =>
                next_state <= DISPLAY_CLEAR_WRITING; --PRINT_STRING_SOLID;
              when "01" =>
                next_state <= DISPLAY_CLEAR_WRITING; --PRINT_STRING_ROTATE;
              when "10" =>
                next_state <= DISPLAY_OFF_BLINK;
				  when "11" =>
                next_state <= DISPLAY_CLEAR_WRITING; --PRINT_STRING_SOLID;
            end case;
				
				debug(14)<='1';								

          when DISPLAY_OFF_BLINK =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"08";
            delay_count <= 32766;
            lcd_fsm <= DELAY;
            next_state <= DISPLAY_CLEAR_WRITING;

				debug(15)<='1';
				
          when DISPLAY_CLEAR_WRITING =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"01";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_ON_WRITING;

				debug(16)<='1';

			when DISPLAY_ON_WRITING =>
            
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"0C";
            lcd_fsm <= WAIT_BF;
				case mode is
              when "00" =>
                next_state <= PRINT_STRING_SOLID;
              when "01" =>
                next_state <= PRINT_STRING_ROTATE;
              when "10" =>
                next_state <= PRINT_STRING_BLINK;
              when "11" =>
                next_state <= PRINT_STRING_SOLID;
            end case;
				
				debug(17)<='1';

        end case;
        --case(lcd_fsm)

      end if;
      --if(spike_50kHz)

    end if;
    --if(reset)

  end process lcd_controller;

end architecture;
