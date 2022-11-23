library ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
 
entity tb_daisyport2 is 
end tb_daisyport2;
 
architecture behaviour of tb_daisyport2 is 
 
constant CLK_PERIOD : time := 20 ns; 
 
-- Signal used to end simulator when we finished submitting our test cases 
signal sim_finished : boolean := false; 
 
signal clk : std_logic; 
signal nReset : std_logic; 
 
-- internal interface (avalon slave) 
signal address : std_logic_vector(3 downto 0); 
signal write : std_logic; 
signal writedata : std_logic_vector(31 downto 0); 
 
-- external interface (conduit) 
signal LEDPort : std_logic; 
signal testPort : std_logic;
 
begin 
 
dut : entity work.daisyport2 
port map(clk => clk, 
	nReset => nReset, 
	address => address, 
	write => write, 
	writedata => writedata, 
	LEDPort => LEDPort,
	testPort => testPort); 
 
clk_generation : process 
 
begin 
 
	if not sim_finished then 
		clk <= '1'; 
		wait for CLK_PERIOD / 2; 
		clk <= '0'; 
		wait for CLK_PERIOD / 2; 
	else 
		wait; 
	end if; 
end process clk_generation; 
 
 
-- Test daisyport 
simulation : process 
 
procedure async_reset is 
 
begin 
 
wait until rising_edge(clk); 
wait for CLK_PERIOD / 4;
 
nReset <= '0'; 
wait for CLK_PERIOD / 2; 
nReset <= '1'; 
end procedure async_reset; 
 
procedure send(constant in1 : in natural; 
constant in2 : in natural) is 
 
begin 
-- Our circuit is sensitive to the rising edge of the CLK, so we 
-- need to be sure to assign signal values such that they are stable 
-- at the next rising edge of the CLK. 
wait until rising_edge(clk); 
-- Assign values to circuit inputs. 
address <= std_logic_vector(to_unsigned(in1, address'length)); 
writedata <= std_logic_vector(to_unsigned(in2, writedata'length)); 
-- OP1, OP2 and START are NOT yet assigned. We have to wait for some 
-- time for the simulator to "propagate" their values. Any 
-- infinitesimal period would work for the simulator to "propagate" 
-- the values. However, our circuit is a sequential circuit 
-- sensitive to the rising edge of CLK, so we need to hold our 
-- signal assignments until the next rising edge of CLK so the 
-- circuit can see them. 
wait until rising_edge(clk); 
-- Remove values from circuit inputs. The circuit works with a PULSE 
-- on its START input, which means that data on the inputs only 
-- needs to be valid when START is high. 
address <= (others => '0'); 
writedata <= (others => '0'); 
end procedure send; 
 
begin 
-- Default values 
address <= (others => '0'); 
writedata <= (others => '0'); 
nReset <= '0'; 
write <= '1'; 
wait for CLK_PERIOD; 
-- Reset the circuit. 
async_reset; 
-- Check test vectors  
 
send(1,11184810); 
send(2,13421772); 
send(3,11184810); 
send(4,13421772); 
write <= '0'; 
wait for CLK_PERIOD*10000000; 
write <= '1'; 
--send(1,11184810); 
--write <= '0'; 
--wait for CLK_PERIOD*10000; 
--send(3,11184810); 
--send(4,11184810); 
--write <= '1'; 
 
-- Instruct "clk_generation" process to halt execution. 
sim_finished <= true; 
-- Make this process wait indefinitely (it will never re-execute from 
-- its beginning again). 
wait; 
end process simulation; 
end architecture behaviour; 
 
 