library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.ALL;

entity spiker_50kHz is
  port(
    --input
      clock_50MHz:  in std_logic;
      reset: in std_logic;

    --output
      spike_50kHz:  out std_logic);
end entity;

architecture main of spiker_50kHz is
  signal counter: integer range 0 to 1023;

  begin
  divider: process ( clock_50MHz, reset)
    begin
 
    if reset = '0' then
      counter <= 0;
    elsif (clock_50MHz'event and clock_50MHz='1') then
      counter <= counter + 1;
    end if;
	 
	 --freq_input = 50E6
   --freq_outpt = 50E3
   --we have to wait 1000 cycles (i.e. 0x3E8)

   if (counter = 1000) then
	   spike_50kHz <= '1';
		counter <= 0;
	 else
	   spike_50kHz <= '0';
	 end if;

  end process divider;

end main;
