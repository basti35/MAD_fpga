-- Se l'enable (KEY3) è alto, copia il valore degli switch sui led.

library ieee;
use ieee.std_logic_1164.all;

entity Led_Pulsanti is
	port 
	(
		-- input
		SW		: in std_logic_vector (17 downto 0);
		KEY	: in	std_logic_vector(3 downto 0);	-- start/stop, clear, nc, nc
		-- output
		LEDR	: out std_logic_vector (17 downto 0)
	);
	
end entity;

architecture main of Led_Pulsanti is
	component copy
		port 
		(
			-- input
			sources	: in std_logic_vector (17 downto 0);
			enable	: in std_logic;
			-- output
			dest		: out std_logic_vector (17 downto 0)
		);
	end component;
	
	begin
		copy_1:	copy port map(SW, KEY(3), LEDR);
end main;
