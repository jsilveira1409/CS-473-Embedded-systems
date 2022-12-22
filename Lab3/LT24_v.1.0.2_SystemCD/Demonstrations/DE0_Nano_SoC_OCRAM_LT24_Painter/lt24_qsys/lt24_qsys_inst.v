	lt24_qsys u0 (
		.clk_clk                                          (<connected-to-clk_clk>),                                          //                                       clk.clk
		.key_external_connection_export                   (<connected-to-key_external_connection_export>),                   //                   key_external_connection.export
		.lcd_reset_n_export                               (<connected-to-lcd_reset_n_export>),                               //                               lcd_reset_n.export
		.lt24_controller_0_conduit_end_cs                 (<connected-to-lt24_controller_0_conduit_end_cs>),                 //             lt24_controller_0_conduit_end.cs
		.lt24_controller_0_conduit_end_rs                 (<connected-to-lt24_controller_0_conduit_end_rs>),                 //                                          .rs
		.lt24_controller_0_conduit_end_rd                 (<connected-to-lt24_controller_0_conduit_end_rd>),                 //                                          .rd
		.lt24_controller_0_conduit_end_wr                 (<connected-to-lt24_controller_0_conduit_end_wr>),                 //                                          .wr
		.lt24_controller_0_conduit_end_data               (<connected-to-lt24_controller_0_conduit_end_data>),               //                                          .data
		.reset_reset_n                                    (<connected-to-reset_reset_n>),                                    //                                     reset.reset_n
		.touch_panel_busy_external_connection_export      (<connected-to-touch_panel_busy_external_connection_export>),      //      touch_panel_busy_external_connection.export
		.touch_panel_pen_irq_n_external_connection_export (<connected-to-touch_panel_pen_irq_n_external_connection_export>), // touch_panel_pen_irq_n_external_connection.export
		.touch_panel_spi_external_MISO                    (<connected-to-touch_panel_spi_external_MISO>),                    //                  touch_panel_spi_external.MISO
		.touch_panel_spi_external_MOSI                    (<connected-to-touch_panel_spi_external_MOSI>),                    //                                          .MOSI
		.touch_panel_spi_external_SCLK                    (<connected-to-touch_panel_spi_external_SCLK>),                    //                                          .SCLK
		.touch_panel_spi_external_SS_n                    (<connected-to-touch_panel_spi_external_SS_n>)                     //                                          .SS_n
	);

