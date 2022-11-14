library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DaisyLED is
	port(
		clk 		:		in std_logic;
		nReset		:		in std_logic;
		
		-- Internal Interfaces
		D1_R		:		in integer;
		D1_G		:		in integer;
		D1_B		:		in integer;
		
		-- External Interface
		DaisyPort:		out integer
		
	);
end DaisyLED;

architecture comp of DaisyLED is 

	signal iRegD1_R :	 std_logic_vector(7 downto 0);
	signal iRegD1_G :	 std_logic_vector(7 downto 0);
	signal iRegD1_B :	 std_logic_vector(7 downto 0);

begin

	DaisyPort <=	D1_G;

end comp;