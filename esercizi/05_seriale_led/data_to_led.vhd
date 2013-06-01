library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity data_to_led is
	port (
	--input
		clk		: in std_logic;
		rx_ready	: in std_logic;
		rx_data	: in std_logic_vector (7 downto 0);
		tx_end	: in std_logic;
		rst		: in std_logic;
		tx_get	: in std_logic;
	--output
	  	led		: out std_logic_vector(7 downto 0);
		tx_data	: out std_logic_vector(7 downto 0);
		tx_req	: out std_logic
	);
end entity;

architecture main of data_to_led is

	-- definition of the states
	type state is (idle,data,transm);

	--states
	signal dtl_fsm			:	state;
	
	--constants
	constant RST_LVL		:	std_logic := '0';


begin

	process(clk)
	begin
		-- if there are data already read send them to led
		if clk'event and clk = '1' then
		
			-- reset procedure: init the state
			if(rst = RST_LVL) then
				dtl_fsm <= idle;
			end if;
			
			--state machine
			case dtl_fsm is
				--idle state: waiting for data
				when idle =>
					if (rx_ready = '1') then
						led <= rx_data;
						dtl_fsm <= data;
					end if;
				--data state: asking for transmission of 'O' meaning OK
				when data =>	 
						tx_req  <= '1';
						tx_data <= "01001111";
						if(tx_get = '1') then
							dtl_fsm <= transm;
						end if;
				--transm state: waiting for end trasmission
				when transm =>
						tx_req <= '0';
						if (tx_end = '1') then
							dtl_fsm <= idle;
						end if;
				end case;	
				
		end if;
		
	end process;
	
end architecture;