library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity clk_divider is
generic(num_clk: natural := 15);

	port(	ck	: in 	std_logic;
			n_cl: in 	std_logic;
			n_ce: in 	std_logic;
			n_rc: out	std_logic);
end clk_divider;

architecture behavior of clk_divider is
signal cnt_clk: integer range 0 to num_clk;
begin
cnt:process(ck, n_cl, n_ce)
	begin
		if(ck'event and ck ='1') then
			if		(n_cl = '0') then	cnt_clk <= num_clk;
			elsif	(n_ce = '0') then
				if(cnt_clk = 0)	 then	cnt_clk <= num_clk;
				else					cnt_clk <= cnt_clk - 1;
				end if;
			end if;
		end if;
	end process;

rlc:process(cnt_clk, n_ce, ck)
	begin
	n_rc <= '1';
	if((cnt_clk = 0) and (n_ce = '0') and (ck = '0')) then
		n_rc <= '0';
	end if;
	end process;
end behavior;