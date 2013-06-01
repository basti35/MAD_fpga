library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity LCD is  
  port(
      type stringone is array (0 to 31) of character;
    --input
      clock_50MHz:  in std_logic;
      spike_50kHz:  in std_logic;

      reset:  in std_logic;
      mode: in std_logic_vector(1 downto 0);
        --mode: 00:SOLID
        --      01:ROTATING
        --      10:BLINKING

      chars_string_display:  in stringone;
        --string to be visualized

    --output
      lcd_rs:   out std_logic;
        --r
      lcd_en:   out std_logic;
      lcd_rw:   out std_logic;
      lcd_on:   out std_logic;
      lcd_blon: out std_logic;

    --inout
      lcd_data: inout std_logic_vector (7 downto 0));

end entity;

architecture main of LCD is
  type state is (
    INIT1, INIT2, INIT3, DELAY, WAIT_BF, WAIT_BF2,
    FUNC_SET, DISPLAY_OFF, DISPLAY_CLEAR, DISPLAY_ON, MODE_SET, PRINT_STRING_SOLID,
    PRINT_STRING_BLINK, PRINT_STRING_ROTATE, RETURN_HOME, LINE2, DISPLAY_OFF_BLINK);
  
  --this is the current state of the state machine
  signal lcd_fsm: state;
  --this is the state that will occur after the delay
  signal next_state: state;

  -- delay to next action counter
  signal delay_count: unsigned(15 downto 0);

  --pointer to current char inside the string
  signal char_pointer: unsigned(4 downto 0);

  --starting index of string (for ROTATE mode)
  signal string_seed: unsigned(4 downto 0);

  --internal signal for lcd read/write (needed to command
  --three-state buffer).
  -- lcd_rw_int = H: ask for reading
  -- lcd_rw_int = L: ask for writing
  signal lcd_rw_int: std_logic;
  signal lcd_data_int: std_logic_vector (7 downto 0);

begin

  --lcd power on
  lcd_on <= '1';
  
  --lcd backlight on
  lcd_blon <= '1';

  --Bidirectional tri-state LCD data bus
  lcd_data <= lcd_data_int when lcd_rw_int = '0' else (others => '0');
  lcd_rw   <= lcd_rw_int;
  
  -- Load string to display
  
  chars_string_display(0) <= chars_string(; -- «««------------------------------------------------------
  
  lcd_controller: process(clock_50MHz, reset)
  
  begin
    if reset = '0' then
      --do the same as INIT1
      lcd_fsm <= INIT1;
      next_state <= INIT2;

      -- from datasheet
      lcd_data_int <= X"38"; 
     
      lcd_en <= '1';
      lcd_rs <= '0';
      lcd_rw_int <= '1';

    elsif(clock_50MHz'event and clock_50MHz = '1') then
      if (spike_50kHz = '1') then
        case lcd_fsm is

          when DELAY =>
            -- variable time width delay state
            -- stay locked here with lcd_enable LOW for (delay_count*20us)

            lcd_en <= '0';
            if (delay_count /= X"0000") then
              delay_count <= delay_count - 1;
            else
              lcd_fsm <= next_state;
            end if;

          when WAIT_BF =>
            -- ask for busy flag reading
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '1';
            lcd_fsm <= WAIT_BF_1;

          when WAIT_BF_1 =>
            -- wait for busy flag to go down
            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '1';
            if(lcd_data(7) = '0') then
              lcd_fsm <= next_state;
            end if;

				
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
            delay_count <= X"00D2";
              --210 count @50kHz = 20us*210 = 4.2 ms
            char_pointer <= (others => '0');

          when INIT2 =>
            --second transmission (see datasheet)
            --after this transm is needed to wait for more than 100us

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            next_state <= INIT3;
            lcd_fsm <= DELAY;
            delay_count <= X"0006";
              --6 count @50kHz = 20us * 6 = 120us
            char_pointer <= (others => '0');

          when INIT3 =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
            next_state <= FUNC_SET;
            lcd_fsm <= WAIT_BF;
            char_pointer <= (others =>'0');

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
            lcd_data_int <= X"38";
            lcd_fsm <= WAIT_BF;
            next_state <= DISPLAY_CLEAR;

          when DISPLAY_CLEAR =>
            
            lcd_en <='1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"38";
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

          when PRINT_STRING_SOLID =>

            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';
            lcd_data_int(7 downto 0) <= chars_string_display(char_pointer);
            
            --if next_char = 'EOF' or both the two lines are completed
            if (chars_string_display(char_pointer+1) = X"FE") or (char_pointer = 31) then
              next_state <= RETURN_HOME;
            --elsif the first line is completed  
            elsif(char_pointer = 15) then
              char_pointer <= char_pointer + 1;
              next_state <= LINE2;
            end if;

            lcd_fsm <= WAIT_BF;

          when PRINT_STRING_ROTATE =>
            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';
            lcd_data_int <= chars_string_display((char_pointer+string_seed) mod 32);
            
            --if next_char = 'EOF' or both the two lines are completed
            if (chars_string_display(((char_pointer + string_seed +1) mod 32) = X"FE")  or (((char_pointer + string_seed) mod 32) = 31)) then
              delay_count <= X"3FFF";
              lcd_fsm <= DELAY;
              next_state <= RETURN_HOME;
              string_seed <= ((string_seed + 1) mod 32);
            --elsif the first line is completed  
            elsif(((char_pointer + string_seed) mod 32) = 15) then
              char_pointer <= char_pointer + 1;
              next_state <= LINE2;
              lcd_fsm <= WAIT_BF;
            end if;

          when PRINT_STRING_BLINK =>

            lcd_en <= '1';
            lcd_rs <= '1';
            lcd_rw_int <= '0';
            lcd_data_int <= chars_string_display(to_integer((char_pointer)*8) to to_integer((char_pointer + 1) * 8-1));
            
            --if next_char = 'EOF' or both the two lines are completed
            if (chars_string_display(char_pointer+1) = X"FE") or (char_pointer = 31) then
              delay_count <= X"3FFF";
              next_state <= RETURN_HOME;
              lcd_fsm <= DELAY;
            --elsif the first line is completed  
            elsif(char_pointer = 15) then
              char_pointer <= char_pointer + 1;
              next_state <= LINE2;
              lcd_fsm <= WAIT_BF;
            end if;

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

          when RETURN_HOME =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"80";
            lcd_fsm <= WAIT_BF;
				char_pointer <= (others => '0');
            case mode is
              when "00" =>
                next_state <= PRINT_STRING_SOLID;
              when "01" =>
                next_state <= PRINT_STRING_ROTATE;
              when "10" =>
                next_state <= DISPLAY_OFF_BLINK;
				  when "11" =>
                next_state <= PRINT_STRING_SOLID;
            end case;

          when DISPLAY_OFF_BLINK =>

            lcd_en <= '1';
            lcd_rs <= '0';
            lcd_rw_int <= '0';
            lcd_data_int <= X"08";
            delay_count <= X"1FFF";
            lcd_fsm <= DELAY;
            next_state <= PRINT_STRING_BLINK;


        end case;
        --case(lcd_fsm)

      end if;
      --if(spike_50kHz)

    end if;
    --if(reset)

  end process lcd_controller;

end architecture;
