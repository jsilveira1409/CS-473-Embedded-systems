	component lt24_qsys is
		port (
			clk_clk                                          : in  std_logic                     := 'X';             -- clk
			key_external_connection_export                   : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			lcd_reset_n_export                               : out std_logic;                                        -- export
			lt24_controller_0_conduit_end_cs                 : out std_logic;                                        -- cs
			lt24_controller_0_conduit_end_rs                 : out std_logic;                                        -- rs
			lt24_controller_0_conduit_end_rd                 : out std_logic;                                        -- rd
			lt24_controller_0_conduit_end_wr                 : out std_logic;                                        -- wr
			lt24_controller_0_conduit_end_data               : out std_logic_vector(15 downto 0);                    -- data
			reset_reset_n                                    : in  std_logic                     := 'X';             -- reset_n
			touch_panel_busy_external_connection_export      : in  std_logic                     := 'X';             -- export
			touch_panel_pen_irq_n_external_connection_export : in  std_logic                     := 'X';             -- export
			touch_panel_spi_external_MISO                    : in  std_logic                     := 'X';             -- MISO
			touch_panel_spi_external_MOSI                    : out std_logic;                                        -- MOSI
			touch_panel_spi_external_SCLK                    : out std_logic;                                        -- SCLK
			touch_panel_spi_external_SS_n                    : out std_logic                                         -- SS_n
		);
	end component lt24_qsys;

	u0 : component lt24_qsys
		port map (
			clk_clk                                          => CONNECTED_TO_clk_clk,                                          --                                       clk.clk
			key_external_connection_export                   => CONNECTED_TO_key_external_connection_export,                   --                   key_external_connection.export
			lcd_reset_n_export                               => CONNECTED_TO_lcd_reset_n_export,                               --                               lcd_reset_n.export
			lt24_controller_0_conduit_end_cs                 => CONNECTED_TO_lt24_controller_0_conduit_end_cs,                 --             lt24_controller_0_conduit_end.cs
			lt24_controller_0_conduit_end_rs                 => CONNECTED_TO_lt24_controller_0_conduit_end_rs,                 --                                          .rs
			lt24_controller_0_conduit_end_rd                 => CONNECTED_TO_lt24_controller_0_conduit_end_rd,                 --                                          .rd
			lt24_controller_0_conduit_end_wr                 => CONNECTED_TO_lt24_controller_0_conduit_end_wr,                 --                                          .wr
			lt24_controller_0_conduit_end_data               => CONNECTED_TO_lt24_controller_0_conduit_end_data,               --                                          .data
			reset_reset_n                                    => CONNECTED_TO_reset_reset_n,                                    --                                     reset.reset_n
			touch_panel_busy_external_connection_export      => CONNECTED_TO_touch_panel_busy_external_connection_export,      --      touch_panel_busy_external_connection.export
			touch_panel_pen_irq_n_external_connection_export => CONNECTED_TO_touch_panel_pen_irq_n_external_connection_export, -- touch_panel_pen_irq_n_external_connection.export
			touch_panel_spi_external_MISO                    => CONNECTED_TO_touch_panel_spi_external_MISO,                    --                  touch_panel_spi_external.MISO
			touch_panel_spi_external_MOSI                    => CONNECTED_TO_touch_panel_spi_external_MOSI,                    --                                          .MOSI
			touch_panel_spi_external_SCLK                    => CONNECTED_TO_touch_panel_spi_external_SCLK,                    --                                          .SCLK
			touch_panel_spi_external_SS_n                    => CONNECTED_TO_touch_panel_spi_external_SS_n                     --                                          .SS_n
		);

