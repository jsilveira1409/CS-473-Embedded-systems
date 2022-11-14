LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY daisy_avalon_interface IS
	PORT ( 	
				clock, resetn : IN STD_LOGIC;
				read, write, chipselect : IN STD_LOGIC;
				writedata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
				--send			:	IN STD_LOGIC;
				byteenable : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
				readdata : OUT STD_LOGIC_VECTOR(71 DOWNTO 0);
				Q : OUT STD_LOGIC_VECTOR(71 DOWNTO 0) ;
				enable_clk	: IN STD_LOGIC
			);
END daisy_avalon_interface;


ARCHITECTURE Structure OF daisy_avalon_interface IS
	SIGNAL local_byteenable : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL to_reg, from_reg : STD_LOGIC_VECTOR(71 DOWNTO 0);
	
	COMPONENT daisyled
		PORT ( 	
					clock, resetn : IN STD_LOGIC;
					readdata : IN STD_LOGIC_VECTOR(71 DOWNTO 0);
					--send		:	IN STD_LOGIC;
					byteenable : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
					Q : OUT STD_LOGIC_VECTOR(71 DOWNTO 0) 
					--enable_clk	: IN STD_LOGIC
				);
	END COMPONENT;

	BEGIN
		to_reg <= writedata;
		
		WITH (chipselect AND write) SELECT
			local_byteenable <= byteenable WHEN '1', "000000000" WHEN OTHERS;
		
		reg_instance: daisyled PORT MAP (clock, resetn, to_reg, local_byteenable, from_reg);
		
		readdata <= from_reg;
		Q <= from_reg;
		
END Structure;