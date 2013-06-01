library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.ALL;


entity spiker_1Hz is  
	port(	ck	: in 	std_logic;	  --main clock (50MHz)
			n_cl: in 	std_logic; --clear if LOW
			n_ce: in 	std_logic; --enable if HIGH
			n_rc: out	std_logic);--reset_count: spike HIGH when count restarts
end entity;

architecture behavior of spiker_1Hz is
   constant max_count : natural := 50000000;			--clock will be divided by this amount
	signal cnt_clk: natural range 0 to max_count;	--signal used for counting

begin

--Description of following process:
--
--In normal operation (clear disabled, enable enabled) a counter will be decreased from max_count-1
--to 0 each rising edge of the clock. When the counter reach 0, the reset_count output (n_rc) is HIGH,
--otherwise it's LOW. Then it can be used as a spike, with frequency = f_main_clock/max_count.
--For our purposes f_main_clock is 50MHz, so max_count is 50000000 in order to have a freq of 1Hz.

cnt:process(ck, n_cl, n_ce)
	begin		
		--if there is a rising edge of clock
		if(ck'event and ck ='1') then		
			if (n_cl = '0') then
				 --if clear is enabled then it restart counting
		  	    cnt_clk <= max_count-1;
			elsif	(n_ce = '1') then
				if (cnt_clk = 0) then
				  --normal operation mode: if the counter reach 0, then restart counting
				  --and set reset_count output HIGH
				  cnt_clk <= max_count-1;
				  n_rc<='1';
				else
				  --normal operation mode: if counter is not 0, then decrease it and 
				  --set reset_count output LOW
				  cnt_clk <= cnt_clk - 1;
				  n_rc<='0';
				end if;
			end if;
		end if;
	end process;
end behavior;