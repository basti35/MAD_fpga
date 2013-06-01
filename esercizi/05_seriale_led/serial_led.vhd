library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity serial_led is
	port (
		--input
			CLOCK_50	: in  std_logic;
			UART_RXD	: in  std_logic;
			KEY		: in  std_logic_vector(3 downto 0);
		--output
			UART_TXD	: out std_logic;
			LEDR		: out std_logic_vector (17 downto 0)
	);
end entity;

architecture main of serial_led is
	
	--seriale		
		constant PARITY_EN	:	std_logic := '0';	
		
		signal RX_READY	: std_logic;
		signal TX_REQ		: std_logic;		
		signal TX_GET		: std_logic;
		signal TX_END		: std_logic;
		signal RX_DATA		: std_logic_vector (7 downto 0);
		signal TX_DATA		: std_logic_vector (7 downto 0);

	component uart is
		port (
			-- Control
			clk			: in	std_logic;		-- Main clock
			rst			: in	std_logic;		-- Main reset
			-- External Interface
			rx				: in	std_logic;		-- RS232 received serial data
			tx				: out	std_logic;		-- RS232 transmitted serial data
			-- RS232/UART Configuration
			par_en		: in	std_logic;		-- Parity bit enable
			-- uPC Interface
			tx_req		: in	std_logic;		-- Request SEND of data
			tx_get		: out	std_logic;		-- Accepted data SEND
			tx_end		: out	std_logic;		-- Data SENDED
			tx_data		: in	std_logic_vector(7 downto 0);	-- Data to transmit
			rx_ready		: out	std_logic;		-- Received data ready to uPC read
			rx_data		: out	std_logic_vector(7 downto 0)	-- Received data 
		);
	end component;
	
	component data_to_led is
		port (
		--input
			clk		: in  std_logic;
			rx_ready	: in  std_logic;
			rx_data	: in  std_logic_vector (7 downto 0);
			tx_end	: in  std_logic;
			rst		: in  std_logic;
			tx_get	: in std_logic;
		--output
			led		: out std_logic_vector(7 downto 0);
			tx_data	: out std_logic_vector(7 downto 0);
			tx_req	: out std_logic
		);
	end component;

	begin
		uart_1:	uart port map(CLOCK_50, KEY(3), UART_RXD, UART_TXD, PARITY_EN, TX_REQ, TX_GET, TX_END, TX_DATA, RX_READY, RX_DATA);
		data_to_led_1: data_to_led port map(CLOCK_50, RX_READY, RX_DATA, TX_END, KEY(3), TX_GET, LEDR(7 downto 0), TX_DATA, TX_REQ);
		LEDR(17) <= TX_END;
end architecture;

