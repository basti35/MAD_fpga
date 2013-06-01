-- Purpose of this program is to read sources and copy the value to dest.
-- Enable is HIGH logic, so the device is working when enable is H.

library ieee;
use ieee.std_logic_1164.all;

entity copy is
	port 
	(
		-- input
		sources	: in std_logic_vector (17 downto 0);
		enable	: in std_logic;
		-- output
		dest		: out std_logic_vector (17 downto 0)
	);
	
end entity;

architecture main of copy is
begin
	process (enable, sources)
	begin
		if (enable='1') then
			-- Read keys and copy to leds
			dest(17 downto 0) <= sources(17 downto 0);
		else
			-- reset leds if enable is low
			dest <= (others => '0');
		end if;
	end process;
end main;