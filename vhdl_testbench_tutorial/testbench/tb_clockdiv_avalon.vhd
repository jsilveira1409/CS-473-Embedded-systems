library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tb_clock_div_avalon is
end tb_clock_div_avalon;

architecture behaviour of tb_clock_div_avalon is

constant CLK_PERIOD : time := 100 ns;

-- adder_sequential PORTS
signal clk : std_logic;
signal reset : std_logic;
signal clock_out : std_logic;

begin
-- Instantiate DUT
dut : entity work.clockdiv_avalon_interface
port map(clk => clk,
reset => reset,
clock_out => clock_out);

-- Generate CLK signal
clk_generation : process
	begin
		clk <= '1';
		wait for CLK_PERIOD / 2;
		clk <= '0';
		wait for CLK_PERIOD / 2;
end process clk_generation;

simulation : process
procedure async_reset is
begin
wait until rising_edge(clk);
wait for CLK_PERIOD / 4;
reset <= '1';
wait for CLK_PERIOD / 2;
reset <= '0';
end procedure async_reset;

begin

wait for CLK_PERIOD*10;

end process simulation;
end architecture behaviour;