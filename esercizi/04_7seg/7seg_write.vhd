library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity lcd_write is
port(	clock_50: in	std_logic;
		key 	: in	std_logic_vector(3 downto 0);	-- start/stop, clear, nc, nc
		sw	 	: in 	std_logic_vector(0 downto 0); -- n_reset
		hex0 	: out	std_logic_vector(6 downto 0);
		ledr	: out	std_logic_vector(1 downto 0));

end lcd_write;


architecture main of lcd_write is
component clk_divider
	generic(num_clk: natural := 15);
	port(	ck	: in 	std_logic;
			n_cl: in 	std_logic;
			n_ce: in 	std_logic;
			n_rc: out	std_logic);
end component;

component cnt_bcd
	port(	ck	: in		std_logic;
			n_ce: in		std_logic;
			n_cl: in		std_logic;
			q	: buffer	std_logic_vector(3 downto 0);
			n_rc: out		std_logic);
end component;

component hex2display7
	port(	hex		: in	std_logic_vector(3 downto 0);
			seg		: out	std_logic_vector(6 downto 0);
			n_rbi	: in 	std_logic;
			n_rbo	: out	std_logic);
end component;

component fsm
port(		ck		: in	std_logic;
			n_cl	: in	std_logic;	-- system reset
			n_st_sp	: in	std_logic;	-- start/stop
			n_reset : in    std_logic;	-- Clear counter chain
			n_run	: out	std_logic;	-- Active low signsl
			n_clr	: out	std_logic);	-- Active low sognal
		
end component;

signal int_nce	: std_logic;
signal int_ncl	: std_logic;
signal int_nrc	: std_logic;
signal bcd		: std_logic_vector(3 downto 0);

begin
fsm_1:	fsm port map(clock_50,sw(0), key(3), key(2),int_nce, int_ncl);
div_clk: clk_divider generic map(num_clk => 27E6) port map(clock_50, int_ncl, int_nce ,int_nrc );
counter: cnt_bcd port map(clock_50, int_nrc, int_ncl, bcd );
decoder: hex2display7 port map(bcd,hex0,'1', open);

ledr(0) <= int_ncl;
ledr(1) <= int_nce;
end main;