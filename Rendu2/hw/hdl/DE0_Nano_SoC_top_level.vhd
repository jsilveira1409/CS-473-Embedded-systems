LIBRARY ieee;
USE ieee.std_logic_1164.all;



ENTITY DE0_Nano_SoC_top_level IS
	PORT ( 	
				GPIO_0           	: INOUT std_logic_vector(35 downto 0);
				FPGA_CLK1_50     	: in    std_logic;
				KEY_N            	: in    std_logic_vector(1 downto 0)
			);
END DE0_Nano_SoC_top_level;



   


ARCHITECTURE Structure OF DE0_Nano_SoC_top_level IS

	component system is
        port (
            clk_clk                  : in  std_logic := 'X'; -- clk
            daisy_0_conduit_end_name : out std_logic         -- name
        );
    end component system;

	
BEGIN

		u0 : component system
        port map (
				clk_clk                  => FPGA_CLK1_50,                      --                     clk.clk
            daisy_0_conduit_end_name => GPIO_0(0)-- daisyport_0_conduit_end.name
			);
		
END Structure;




    