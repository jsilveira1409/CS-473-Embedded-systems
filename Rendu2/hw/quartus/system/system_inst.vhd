	component system is
		port (
			clk_clk                  : in  std_logic := 'X'; -- clk
			daisy_0_conduit_end_name : out std_logic         -- name
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                  => CONNECTED_TO_clk_clk,                  --                 clk.clk
			daisy_0_conduit_end_name => CONNECTED_TO_daisy_0_conduit_end_name  -- daisy_0_conduit_end.name
		);

