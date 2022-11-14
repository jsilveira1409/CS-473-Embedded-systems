library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity DaisyLED is
	port(
		clk 		:		in std_logic;
		nReset		:		in std_logic;
		
		-- Internal Interfaces
		address : in std_logic_vector(2 downto 0);
		write : in std_logic;
		read : in std_logic;
		writedata : in std_logic_vector(7 downto 0);
		readdata : out std_logic_vector(7 downto 0);
		
		
		-- External Interface
		DaisyPort:		out std_logic_vector(7 downto 0)
		
	);
end DaisyLED;

architecture comp of DaisyLED is 

	signal iRegD1_R :	 std_logic_vector(7 downto 0);
	signal iRegD1_G :	 std_logic_vector(7 downto 0);
	signal iRegD1_B :	 std_logic_vector(7 downto 0);
	
begin

end comp;