-- attivando l'enable carica i dati da source su un registro a 18 bit
-- disattivando l'enable ruota il registro e lo spedisce a des

library ieee;
use ieee.std_logic_1164.all;

entity load_and_rotate is
	port 
	(
		-- input
		sources	: in std_logic_vector (17 downto 0);
		enable	: in std_logic;
		ck			: in std_logic;		
		-- output
		dest		: out std_logic_vector (17 downto 0)
	);
	
end entity;

architecture main of load_and_rotate is
	signal mem:  std_logic_vector (17 downto 0);
	
begin

	process (ck, enable)
	begin
	   if (ck'event and ck='1') then
			--  rotate left mem register
			mem(17 downto 1) <= mem(16 downto 0);
			mem(0) <= mem(17);
		end if;
		
		if (enable='0') then
			-- when enable is low, load mem from sources
			mem(17 downto 0) <= sources(17 downto 0);
		else
			--when enable is HIGH, push mem to dest
			dest (17 downto 0) <= mem (17 downto 0);
		end if;

	end process;
end main;