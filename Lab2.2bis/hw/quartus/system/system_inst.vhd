	component system is
		port (
			clk_clk                                      : in  std_logic := 'X'; -- clk
			daisyport_0_conduit_end_writeresponsevalid_n : out std_logic;        -- writeresponsevalid_n
			reset_reset_n                                : in  std_logic := 'X'  -- reset_n
		);
	end component system;

	u0 : component system
		port map (
			clk_clk                                      => CONNECTED_TO_clk_clk,                                      --                     clk.clk
			daisyport_0_conduit_end_writeresponsevalid_n => CONNECTED_TO_daisyport_0_conduit_end_writeresponsevalid_n, -- daisyport_0_conduit_end.writeresponsevalid_n
			reset_reset_n                                => CONNECTED_TO_reset_reset_n                                 --                   reset.reset_n
		);

