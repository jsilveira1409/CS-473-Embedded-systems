LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.register_file_pkg.all;


entity top is
	
	port(
		--global signals
		clk : in std_logic;
		nReset : in std_logic;
		
		-- avalong master interface(DMA)
		address : out std_logic_vector(31 downto 0);
		read : out std_logic;
		readdata : in std_logic_vector(15 downto 0);
		readdatavalid : in std_logic;
		wait_req : in std_logic;
		burstcount : out std_logic_vector(4 downto 0);
		
		
		