	component unsaved is
		port (
			clk_clk : in std_logic := 'X'  -- clk
		);
	end component unsaved;

	u0 : component unsaved
		port map (
			clk_clk => CONNECTED_TO_clk_clk  -- clk.clk
		);

