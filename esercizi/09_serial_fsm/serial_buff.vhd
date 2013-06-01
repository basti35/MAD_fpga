library ieee;
use ieee.std_logic_1164.ALL;

entity serial_buffer is
	port (
	--input
    clk : in std_logic;
    rx_ready : in std_logic;
    rx_data :  in std_logic_vector(7 downto 0);
    rx_reset : in std_logic;

	--output
		rx_data_buf	: out std_logic_vector(7 downto 0);
		rx_ready_buf : out std_logic);
end entity;

architecture main of serial_buffer is
begin
  type state is (no_data_idle, data, data_idle);
  --no_data_idle: waiting for rx_ready going up;
  --data: data came, read them and pass toward. Wait for rx_reset;
  --data_idle: waiting for rx_ready going down;

  signal fsm : state;

	process(clk)
	begin
    if(clk'event and clk='1') then
      if rx_reset='0'then
        rx_ready_buf <= '0';
      else
        case fsm is
          when idle=>
            if rx_ready

    end if;
	end process;
	
end architecture;
