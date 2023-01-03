// ============================================================================
// Copyright (c) 2014 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//  
//  
//                     web: http://www.terasic.com/  
//                     email: support@terasic.com
//
// ============================================================================
//Date:  Thu Dec  4 10:07:47 2014
// ============================================================================

//`define ENABLE_HPS


module DE0_Nano_SoC_golden_top(

      ///////// ADC /////////
      output             ADC_CONVST,
      output             ADC_SCK,
      output             ADC_SDI,
      input              ADC_SDO,

      ///////// ARDUINO /////////
      inout       [15:0] ARDUINO_IO,
      inout              ARDUINO_RESET_N,

      ///////// FPGA /////////
      input              FPGA_CLK1_50,
      input              FPGA_CLK2_50,
      input              FPGA_CLK3_50,

      ///////// GPIO /////////
      inout       [35:0] GPIO_1,

`ifdef ENABLE_HPS
      ///////// HPS /////////
      inout              HPS_CONV_USB_N,
      output      [14:0] HPS_DDR3_ADDR,
      output      [2:0]  HPS_DDR3_BA,
      output             HPS_DDR3_CAS_N,
      output             HPS_DDR3_CKE,
      output             HPS_DDR3_CK_N,
      output             HPS_DDR3_CK_P,
      output             HPS_DDR3_CS_N,
      output      [3:0]  HPS_DDR3_DM,
      inout       [31:0] HPS_DDR3_DQ,
      inout       [3:0]  HPS_DDR3_DQS_N,
      inout       [3:0]  HPS_DDR3_DQS_P,
      output             HPS_DDR3_ODT,
      output             HPS_DDR3_RAS_N,
      output             HPS_DDR3_RESET_N,
      input              HPS_DDR3_RZQ,
      output             HPS_DDR3_WE_N,
      output             HPS_ENET_GTX_CLK,
      inout              HPS_ENET_INT_N,
      output             HPS_ENET_MDC,
      inout              HPS_ENET_MDIO,
      input              HPS_ENET_RX_CLK,
      input       [3:0]  HPS_ENET_RX_DATA,
      input              HPS_ENET_RX_DV,
      output      [3:0]  HPS_ENET_TX_DATA,
      output             HPS_ENET_TX_EN,
      inout              HPS_GSENSOR_INT,
      inout              HPS_I2C0_SCLK,
      inout              HPS_I2C0_SDAT,
      inout              HPS_I2C1_SCLK,
      inout              HPS_I2C1_SDAT,
      inout              HPS_KEY,
      inout              HPS_LED,
      inout              HPS_LTC_GPIO,
      output             HPS_SD_CLK,
      inout              HPS_SD_CMD,
      inout       [3:0]  HPS_SD_DATA,
      output             HPS_SPIM_CLK,
      input              HPS_SPIM_MISO,
      output             HPS_SPIM_MOSI,
      inout              HPS_SPIM_SS,
      input              HPS_UART_RX,
      output             HPS_UART_TX,
      input              HPS_USB_CLKOUT,
      inout       [7:0]  HPS_USB_DATA,
      input              HPS_USB_DIR,
      input              HPS_USB_NXT,
      output             HPS_USB_STP,
`endif /*ENABLE_HPS*/

      ///////// KEY /////////
      input       [1:0]  KEY,

      ///////// LED /////////
      output      [7:0]  LED,

      ///////// SW /////////
      input       [3:0]  SW,
		
		//////////// GPIO_0, GPIO_0 connect to LT24 - 2.4" LCD and Touch //////////
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

wire reset_n;

//=======================================================
//  Structural coding
//=======================================================
assign LT24_LCD_ON = 1'b1; //default on

assign reset_n = 1'b1;

	
 lt24_qsys u0 (
	  .clk_clk                                          ( FPGA_CLK1_50),                                          //                                       clk.clk
	  .reset_reset_n                                    (reset_n),                                    //                                     reset.reset_n
	  .lcd_reset_n_export                               (LT24_RESET_N),                               //                               lcd_reset_n.export
	  .key_external_connection_export                   (KEY),                   //                   key_external_connection.export
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
	  .lt24_controller_0_conduit_end_data               (LT24_D )              //                                          .data
 );



endmodule
