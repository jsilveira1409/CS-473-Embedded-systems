	component system2 is
		port (
			clk_clk         : in  std_logic                     := 'X'; -- clk
			to_led_readdata : out std_logic_vector(71 downto 0)         -- readdata
		);
	end component system2;

	u0 : component system2
		port map (
			clk_clk         => CONNECTED_TO_clk_clk,         --    clk.clk
			to_led_readdata => CONNECTED_TO_to_led_readdata  -- to_led.readdata
		);

