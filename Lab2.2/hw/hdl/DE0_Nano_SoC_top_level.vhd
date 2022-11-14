LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY DE0_Nano_SoC_top_level IS
	PORT ( 	
				GPIO_0           	: INOUT std_logic_vector(35 downto 0);
				FPGA_CLK1_50     : in    std_logic;
				KEY_N            : in    std_logic_vector(1 downto 0)
				
			);
END DE0_Nano_SoC_top_level;


ARCHITECTURE Structure OF DE0_Nano_SoC_top_level IS
	
	COMPONENT system2 IS
		PORT ( 	
			reset_reset_n                    : in  std_logic                    := 'X'; -- reset_n
			DaisyPort_LEDPort_export : out std_logic;        -- export
			clk_clk                          : in  std_logic                    := 'X'  -- clk
				);
	END COMPONENT system2;

BEGIN
		U0: system2 PORT MAP (
			reset_reset_n                    => KEY_N(0),
			DaisyPort_LEDPort_export =>	GPIO_0(0),
			clk_clk                          => FPGA_CLK1_50    
				);
		
END Structure;