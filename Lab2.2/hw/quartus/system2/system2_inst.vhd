	component system2 is
		port (
			clk_clk                                      : in  std_logic := 'X'; -- clk
			daisyport_0_conduit_end_writeresponsevalid_n : out std_logic         -- writeresponsevalid_n
		);
	end component system2;

	u0 : component system2
		port map (
			clk_clk                                      => CONNECTED_TO_clk_clk,                                      --                     clk.clk
			daisyport_0_conduit_end_writeresponsevalid_n => CONNECTED_TO_daisyport_0_conduit_end_writeresponsevalid_n  -- daisyport_0_conduit_end.writeresponsevalid_n
		);

