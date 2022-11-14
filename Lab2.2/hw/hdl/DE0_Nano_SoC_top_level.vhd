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

	SIGNAL to_DAISYLED : STD_LOGIC_VECTOR(71 DOWNTO 0);
	
	COMPONENT system2 IS
		PORT ( 	
					clk_clk 				: IN STD_LOGIC;
					to_led_readdata 	: OUT std_logic_vector(71 downto 0)         
				);
	END COMPONENT system2;

BEGIN
		U0: system2 PORT MAP (
					clk_clk 				=> CLOCK_50,
					to_led_readdata 	=> to_DAISYLED
				);
		
END Structure;