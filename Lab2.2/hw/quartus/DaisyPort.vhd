library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DaisyPort is
	port(
	clk			: in std_logic;
	resetn		: in std_logic;
	enable		: in std_logic;
	
	-- internal interface (avalon slave)
	address		: in std_logic_vector(3 downto 0);
	write			: in std_logic;
	writedata	: in std_logic_vector(7 downto 0);
	
	
	
	-- external interface (conduit)
	LedPort 		: out std_logic_vector(7 downto 0)
	);
end DaisyPort;

architecture behaviour of DaisyPort is
	signal iRegEnable		: std_logic_vector(7 downto 0);
	signal iRegD0Green	: std_logic_vector(7 downto 0);
	signal iRegD0Red		: std_logic_vector(7 downto 0);
	signal iRegD0Blue		: std_logic_vector(7 downto 0);
	signal iRegD1Green	: std_logic_vector(7 downto 0);
	signal iRegD1Red		: std_logic_vector(7 downto 0);
	signal iRegD1Blue		: std_logic_vector(7 downto 0);

begin



end behaviour;