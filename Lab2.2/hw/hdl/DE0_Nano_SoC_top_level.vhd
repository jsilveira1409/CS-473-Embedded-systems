LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DE0_Nano_SoC_top_level IS
	PORT ( 	
				GPIO_0           	: INOUT std_logic_vector(35 downto 0);
				CLOCK_50 			: IN STD_LOGIC;
				KEY 					: IN STD_LOGIC_VECTOR(0 DOWNTO 0)
				
			);
END DE0_Nano_SoC_top_level;


ARCHITECTURE Structure OF DE0_Nano_SoC_top_level IS

	
	COMPONENT system2 IS
		PORT ( 	
					clk_clk 				: IN STD_LOGIC
				);
	END COMPONENT system2;

BEGIN
		U0: system2 PORT MAP (
					clk_clk 				=> CLOCK_50
				);
		
END Structure;