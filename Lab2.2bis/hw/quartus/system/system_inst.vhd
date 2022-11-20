	component system is
		port (
			clk_clk                      : in  std_logic := 'X'; -- clk
			reset_reset_n                : in  std_logic := 'X'; -- reset_n
			daisyport_0_conduit_end_name : out std_logic         -- name
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                      => CONNECTED_TO_clk_clk,                      --                     clk.clk
			reset_reset_n                => CONNECTED_TO_reset_reset_n,                --                   reset.reset_n
			daisyport_0_conduit_end_name => CONNECTED_TO_daisyport_0_conduit_end_name  -- daisyport_0_conduit_end.name
		);

