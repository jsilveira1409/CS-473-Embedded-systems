
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module C5G_LT24_Painter(

	//////////// CLOCK //////////
	input 		          		CLOCK_125_p,
	input 		          		CLOCK_50_B5B,
	input 		          		CLOCK_50_B6A,
	input 		          		CLOCK_50_B7A,
	input 		          		CLOCK_50_B8A,

	//////////// LED //////////
	output		     [7:0]		LEDG,
	output		     [9:0]		LEDR,

	//////////// KEY //////////
	input 		          		CPU_RESET_n,
	input 		     [3:0]		KEY,

	//////////// SW //////////
	input 		     [9:0]		SW,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,

	//////////// HDMI-TX //////////
	output		          		HDMI_TX_CLK,
	output		    [23:0]		HDMI_TX_D,
	output		          		HDMI_TX_DE,
	output		          		HDMI_TX_HS,
	input 		          		HDMI_TX_INT,
	output		          		HDMI_TX_VS,

	//////////// ADC SPI //////////
	output		          		ADC_CONVST,
	output		          		ADC_SCK,
	output		          		ADC_SDI,
	input 		          		ADC_SDO,

	//////////// Audio //////////
	input 		          		AUD_ADCDAT,
	inout 		          		AUD_ADCLRCK,
	inout 		          		AUD_BCLK,
	output		          		AUD_DACDAT,
	inout 		          		AUD_DACLRCK,
	output		          		AUD_XCK,

	//////////// I2C for Audio/HDMI-TX/Si5338/HSMC //////////
	output		          		I2C_SCL,
	inout 		          		I2C_SDA,

	//////////// SDCARD //////////
	output		          		SD_CLK,
	inout 		          		SD_CMD,
	inout 		     [3:0]		SD_DAT,

	//////////// Uart to USB //////////
	input 		          		UART_RX,
	output		          		UART_TX,

	//////////// SRAM //////////
	output		    [17:0]		SRAM_A,
	output		          		SRAM_CE_n,
	inout 		    [15:0]		SRAM_D,
	output		          		SRAM_LB_n,
	output		          		SRAM_OE_n,
	output		          		SRAM_UB_n,
	output		          		SRAM_WE_n,

	//////////// GPIO, GPIO connect to LT24 - 2.4" LCD and Touch //////////
	input 		          		LT24_ADC_BUSY,
	output		          		LT24_ADC_CS_N,
	output		          		LT24_ADC_DCLK,
	output		          		LT24_ADC_DIN,
	input 		          		LT24_ADC_DOUT,
	input 		          		LT24_ADC_PENIRQ_N,
	output		          		LT24_CS_N,
	output		    [15:0]		LT24_D,
	output		          		LT24_LCD_ON,
	output		          		LT24_RD_N,
	output		          		LT24_RESET_N,
	output		          		LT24_RS,
	output		          		LT24_WR_N
);



//=======================================================
//  REG/WIRE declarations
//=======================================================




//=======================================================
//  Structural coding
//=======================================================
assign LT24_LCD_ON = 1'b1; //default on



 lt24_qsys u0 (
	  .clk_clk            (CLOCK_50_B5B),            //         clk.clk
	  .reset_reset_n      (1'b1),      //       reset.reset_n
	  .key_external_connection_export                  (KEY),                    //                   key_external_connection.export
	  .lcd_reset_n_export                              (LT24_RESET_N), // lcd_reset_n.export
	  ////touch panel interface
	  .touch_panel_spi_external_MISO                    (LT24_ADC_DOUT),                    //                  touch_panel_spi_external.MISO
	  .touch_panel_spi_external_MOSI                    (LT24_ADC_DIN),                    //                                          .MOSI
	  .touch_panel_spi_external_SCLK                    (LT24_ADC_DCLK),                    //                                          .SCLK
	  .touch_panel_spi_external_SS_n                    (LT24_ADC_CS_N),                    //                                          .SS_n
	  .touch_panel_pen_irq_n_external_connection_export (LT24_ADC_PENIRQ_N), // touch_panel_pen_irq_n_external_connection.export
	  .touch_panel_busy_external_connection_export      (LT24_ADC_BUSY),       //      touch_panel_busy_external_connection.export
     .lt24_controller_0_conduit_end_cs                 (LT24_CS_N ),                 //                                          .cs
     .lt24_controller_0_conduit_end_rs                 (LT24_RS ),                 //                                          .rs
     .lt24_controller_0_conduit_end_rd                 (LT24_RD_N ),                 //                                          .rd
     .lt24_controller_0_conduit_end_wr                 (LT24_WR_N),                 //                                          .wr
     .lt24_controller_0_conduit_end_data               (LT24_D ),               //                                          .data
     .altpll_0_areset_conduit_export                   ( ),                   //                   altpll_0_areset_conduit.export
     .altpll_0_locked_conduit_export                   ( ),                   //                   altpll_0_locked_conduit.export
     .altpll_0_phasedone_conduit_export                ( )                 //                altpll_0_phasedone_conduit.export
	
 );
 


endmodule
