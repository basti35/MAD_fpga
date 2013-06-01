--Description
--
--We want to blink leds, with different Ton and Toff.
-- Ton is set with switch(7 downto 0)
-- Toff is set with switch(17 downto 10)

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;

entity lampeggio_asimmetrico is  
  port(
    --input
      clock_50MHz:  in std_logic;
      spike_1Hz:  in std_logic;
		switch:	in std_logic_vector(17 downto 0);

      reset:  in std_logic;

    --output
		ledr:	 out std_logic_vector(17 downto 0));

end entity;

architecture main of lampeggio_asimmetrico is
  type state is (
      LEDS_ON, LEDS_OFF, DELAY);
  
  --this is the current state of the state machine
  signal fsm: state;
  --this is the state that will occur after the delay
  signal next_state: state;
  
  -- delay to next action counter
  constant max_delay: natural :=65535;
  signal delay_count: natural range 0 to max_delay;

begin   
  lampeggio: process(clock_50MHz, reset)
  begin
    if reset='0' then
      fsm <= LEDS_ON;
      next_state <= LEDS_OFF;
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
				
			
			when LEDS_ON =>
			
			  -- converts std_logic_vector to integer. -> Needs explicitly to write if SIGNED or UNSIGNED
			  delay_count <= to_integer(unsigned(switch(7 downto 0)));
			  
			  fsm<=DELAY;
			  next_state <= LEDS_OFF;
			  
			  ledr <= ( others=> '1');
			  
			when LEDS_OFF =>
			
			  -- converts std_logic_vector to integer. -> Needs explicitly to write if SIGNED or UNSIGNED
			  delay_count <= to_integer(unsigned(switch(17 downto 10)));
			  
			  fsm <= DELAY;
			  next_state <= LEDS_ON;
			  
			  ledr <= ( others=> '0');

        end case;
        --case(fsm)

      end if;
      --if(spike_1Hz)

    end if;
    --if(reset)

  end process;

end architecture;
