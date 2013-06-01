-- attivando l'enable carica i dati dagli switches sui led
-- disattivando l'enable comincia a ruotare i led verso dx
-- il sistema è sincrono

library ieee;
use ieee.std_logic_1164.all;

entity rotate_leds is
	port 
	(
		-- input
		SW			: in std_logic_vector (17 downto 0);
		KEY		: in std_logic_vector (3 downto 0);
		-- output
		LEDR		: out std_logic_vector (17 downto 0)
	);
	
end entity;


architecture main of rotate_leds is	
	component load_and_rotate is
		port 
		(
			-- input
			sources	: in std_logic_vector (17 downto 0);
			enable	: in std_logic;
			ck			: in std_logic;		
			-- output
			dest		: out std_logic_vector (17 downto 0)
		);
	end component;

	begin
		load_and_rotate_1:	load_and_rotate port map(SW, KEY(3), KEY(2), LEDR);
end main;