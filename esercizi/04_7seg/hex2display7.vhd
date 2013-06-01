library ieee;
use ieee.std_logic_1164.all;
---------------------------------------------------------------
-- This device accepts a 4-bit binary code and produces output
-- drive to the appropriate segments of the 7-segment display.
-- It has a hexadecimal decode format which produces numeric
-- codes 0 thru 9 and alpha codes A through F using upper and 
-- lower case fonts.
-- Leading edge zero suppression is obtained by connecting
-- the Ripple Blanking Output (RBO) of a decoder to the Rip-
-- ple Blanking Input (RBI) of the next lower stage device. The
-- most significant decoder stage should have the RBI input
-- grounded; and since suppression of the least significant in-
-- teger zero in a number is not usually desired, the RBI input
-- of this decoder stage should be left open.
----------------------------------------------------------------

entity hex2display7 is
	port(	hex		: in	std_logic_vector(3 downto 0);
			seg		: out	std_logic_vector(6 downto 0);
			n_rbi	: in 	std_logic;
			n_rbo	: out	std_logic);
end hex2display7;

architecture behavior of hex2display7 is
begin
process(n_rbi,hex)
begin

	if(n_rbi = '0' and hex="0000") then	
		seg <="1111111"; -- blank
		n_rbo <= '0';
	else
		n_rbo <= '1';
		if		(hex="0000") then	seg <="1000000"; -- 0
		elsif	(hex="0001") then	seg <="1111001"; -- 1
		elsif	(hex="0010") then	seg <="0100100"; -- 2
		elsif	(hex="0011") then	seg <="0110000"; -- 3
		elsif	(hex="0100") then	seg <="0011001"; -- 4
		elsif	(hex="0101") then	seg <="0010010"; -- 5
		elsif	(hex="0110") then	seg <="0000010"; -- 6
		elsif	(hex="0111") then	seg <="1111000"; -- 7
		elsif	(hex="1000") then	seg <="0000000"; -- 8
		elsif	(hex="1001") then	seg <="0010000"; -- 9
		elsif	(hex="1010") then	seg <="0001000"; -- a
		elsif	(hex="1011") then	seg <="0000011"; -- b
		elsif	(hex="1100") then	seg <="1000110"; -- c
		elsif	(hex="1101") then	seg <="0100001"; -- d
		elsif	(hex="1110") then	seg <="0000110"; -- e
		else							seg <="0001110"; -- f
		end if;
	end if;
end process;
end behavior;
