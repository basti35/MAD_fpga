library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity lampeggio_asimmetrico_uns is  
  port(
    --input
      clock_50MHz:  in std_logic;
      spike_50kHz:  in std_logic;

      reset:  in std_logic;

    --output
		ledr:	 out std_logic_vector(17 downto 0));
		
end entity;

architecture main of lampeggio_asimmetrico_uns is
  type state is (
      LEDS_ON, LEDS_OFF, DELAY);
  
  --this is the current state of the state machine
  signal fsm: state;
  --this is the state that will occur after the delay
  signal next_state: state;

  -- delay to next action counter
  signal delay_count: integer (7 downto 0);

begin  
  
  lampeggio: process(clock_50MHz, reset)
  begin
    if reset='0' then
      fsm <= LEDS_ON;
      next_state <= LEDS_OFF;
		ledr <= (others => '1');

    elsif(spike_50kHz='1') then
        case fsm is

          when DELAY =>
            -- variable time width delay state
            -- stay locked here with lcd_enable LOW for (delay_count*20us)
            if (delay_count=0) then
              fsm <= next_state;
            else
              delay_count <= delay_count-1;
            end if;
				
			
			when LEDS_ON =>
			
			  delay_count <= 50000;
			  fsm <= DELAY;
			  next_state <= LEDS_OFF;
			  
			  ledr <= ( others=> '1');
			  
			when LEDS_OFF =>
			
			  delay_count <= 10000;
			  fsm <= DELAY;
			  next_state <= LEDS_ON;
			  
			  ledr <= ( others=> '0');

        end case;
        --case(lcd_fsm)

    --  end if;
      --if(spike_50kHz)

    end if;
    --if(reset)

  end process;

end architecture;
