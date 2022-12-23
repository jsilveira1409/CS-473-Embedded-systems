
module lt24_qsys (
	clk_clk,
	key_external_connection_export,
	lcd_reset_n_export,
	lt24_controller_0_conduit_end_cs,
	lt24_controller_0_conduit_end_rs,
	lt24_controller_0_conduit_end_rd,
	lt24_controller_0_conduit_end_wr,
	lt24_controller_0_conduit_end_data,
	reset_reset_n,
	touch_panel_busy_external_connection_export,
	touch_panel_pen_irq_n_external_connection_export,
	touch_panel_spi_external_MISO,
	touch_panel_spi_external_MOSI,
	touch_panel_spi_external_SCLK,
	touch_panel_spi_external_SS_n);	

	input		clk_clk;
	input	[3:0]	key_external_connection_export;
	output		lcd_reset_n_export;
	output		lt24_controller_0_conduit_end_cs;
	output		lt24_controller_0_conduit_end_rs;
	output		lt24_controller_0_conduit_end_rd;
	output		lt24_controller_0_conduit_end_wr;
	output	[15:0]	lt24_controller_0_conduit_end_data;
	input		reset_reset_n;
	input		touch_panel_busy_external_connection_export;
	input		touch_panel_pen_irq_n_external_connection_export;
	input		touch_panel_spi_external_MISO;
	output		touch_panel_spi_external_MOSI;
	output		touch_panel_spi_external_SCLK;
	output		touch_panel_spi_external_SS_n;
endmodule
