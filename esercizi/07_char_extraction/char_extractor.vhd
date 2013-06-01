library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity char_extractor is  
  port(
    --input
      clock_50MHz:  in std_logic;
      spike_1Hz:  in std_logic;
		switch:	in std_logic_vector(17 downto 0);

      reset:  in std_logic;

    --output
		ledr:	 out std_logic_vector(17 downto 0);
		ledg:  out std_logic_vector(7 downto 0));
		
end entity;

architecture main of char_extractor is
  type state is (
      INIT, LOAD_CHAR, DELAY);
  
  --this is the current state of the state machine
  signal fsm: state;
  --this is the state that will occur after the delay
  signal next_state: state;
  
  -- delay to next action counter
  constant max_delay: natural :=65535;  
  signal delay_count: natural range 0 to max_delay;
  
  --string that contains the chars to be extracted (16 chars * 2 lines * 8 bit = 256)
  signal chars_string_display:  std_logic_vector (0 to 255) := X"6162636465666768697061626364656667686970616263646566676869706162";  

  --pointer to the current char in the string
  signal char_pointer: natural range 0 to 31;
  
  --counter used as counter for the eight bits of char
  signal char_position: natural range 0 to 7;

begin   
  extractor: process(clock_50MHz, reset)
  begin
    if reset='0' then
      fsm <= INIT;
		char_pointer <= 0;
		ledr <= (others => '1');

    elsif (clock_50MHz'event and clock_50MHz='1') then
	   if(spike_1Hz='1') then
        case fsm is

          when DELAY =>
            -- variable time width delay state
            -- stay locked here with lcd_enable LOW for (delay_count*20us)
            if (delay_count=0) then
              fsm <= next_state;
            else
              delay_count <= delay_count-1;
            end if;
				
			
			when INIT =>

			  char_pointer <= 0;
			  delay_count <= 1;
			  fsm<=DELAY;
			  next_state <= LOAD_CHAR;
			  
			  ledr <= ( others=> '1');
			  
			when LOAD_CHAR =>
			
			  delay_count <= 2;
			  fsm <= DELAY;
			  next_state <= LOAD_CHAR;
			  
           for char_position in 0 to 7 loop
             ledg(char_position) <= chars_string_display(char_pointer*8+7-char_position);
           end loop;
			  if (char_pointer=31) then
				 char_pointer <= 0;
			  else
				 char_pointer <= char_pointer+1;
			  end if;

			  ledr <= ( others=> '0');

        end case;
        --case(fsm)

      end if;
      --if(spike_1Hz)

    end if;
    --if(reset)

  end process;

end architecture;
