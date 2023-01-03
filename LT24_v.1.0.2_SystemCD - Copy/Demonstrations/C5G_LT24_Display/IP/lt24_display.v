////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    File name    : lt24_display.v                                           //
//    Version      : V1.0                                                     //
//    Author       : Fang                                                     //
//    Create Date  : 2014.09.04                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//              lt24_display overview                                         //
//  This lt24_display module is top of lt24_display project. This module      //
//  includes display, cmd2lcd, pat_update and timer modules.                  //
////////////////////////////////////////////////////////////////////////////////
//    History :                                                               //
//  20140904 :                                                                //
//    1. New Create. by Fang                                                  //
//  20140923 :                                                                //
//    1. Modify, remove RAM and re-design. by Fang                            //
//  20140925 :                                                                //
//    1. Add, add sleep_off. by Fang                                          //
////////////////////////////////////////////////////////////////////////////////

module lt24_display (
  ////  SYSTEM  ////
    //// output ////
    frame_update,

    //// input ////
    clk,
    rst_n,
    
  ////  LCD  ////
    //// output ////
    csn,
    data_cmdn,
    wrn,
    rdn,

    //// inout ////
    data_lcd,
    
  ////  ADC(touch)  ////
    //// output ////
    adc_clk,
    adc_cs_n,
    adc_data_to,

    //// input ////
    adc_busy,
    adc_data_from,
    adc_penint
    
    ) ;  // lt24_display

  ////  ADC(touch)  ////
    input adc_busy ;
    input adc_data_from ;
    input adc_penint ;
    
    output adc_clk ;
    output adc_cs_n ;
    output adc_data_to ;

  ////  LCD  ////
    inout [15:0] data_lcd ;
    
    wire [15:0] data_lcd ;
    
    output csn ;
    output data_cmdn ;
    output wrn ;
    output rdn ;

  ////  SYSTEM  ////
    input clk ;
    input rst_n ;
    
    //// output ////
    output frame_update ;


////////////////  internal wire and registers  /////////////////////////////////
////////////////  cmd2lcd  ////////////////
    wire        lcd_rdata_valid ;
    wire [15:0] lcd_rdata ;
    wire        lcd_write_ack ;
    wire        lcd_cmd_finish ;
    wire        lcd_wrphase_finish ;  // m- 20140923(1)
////////////////  cmd2lcd end  ////////////////

////////////////  pat_update  ////////////////
    wire        frame_upd_start ;  // a-4 20140923(1)
    wire        single_upd_start ;
    wire [8:0]  x_coordinate ;
    wire [8:0]  y_coordinate ;
    wire        buf_data_valid ;  // m-2 20140923(1)
    wire [15:0] buf_data ;
////////////////  pat_update end  ////////////////

////////////////  display  ////////////////
    wire        sleep_off ;  // a- 20140925(1)
    wire        buf_data_ack ;  // m- 20140923(1)
    wire        lcd_cmd_valid ;
    wire [7:0]  lcd_cmd ;
    wire        lcd_rcmd_enb ;
    wire [15:0] lcd_cmd_cycle ;
    wire        lcd_wdata_valid ;
    wire [15:0] lcd_wdata ;
    wire        lcd_read_ack ;
////////////////  display end  ////////////////

////////////////  timer  ////////////////
    wire        trigger_33ms ;
////////////////  timer end  ////////////////
////////////////  internal wire and registers end  /////////////////////////////

cmd2lcd cmd2lcd(
  ////  SYSTEM  ////
    //// input ////
    .clk                        (clk            ),
    .rst_n                      (rst_n          ),

  ////  LT24_Command  ////
    //// output ////
    .data_rd_valid              (lcd_rdata_valid ),
    .data_rd                    (lcd_rdata       ),
    .ack_wr                     (lcd_write_ack   ),
    .cmd_finish                 (lcd_cmd_finish  ),
    .wrphase_finish             (lcd_wrphase_finish),  // m- 20140923(1)

    //// input ////
    .cmd_valid                  (lcd_cmd_valid  ),
    .cmd                        (lcd_cmd        ),
    .read_enb                   (lcd_rcmd_enb   ),
    .cmd_cycle                  (lcd_cmd_cycle  ),
    .data_wr_valid              (lcd_wdata_valid),
    .data_wr                    (lcd_wdata      ),
    .ack_rd                     (lcd_read_ack   ),

  ////  LT24  ////
    //// output ////
    .csn                        (csn            ),
    .data_cmdn                  (data_cmdn      ),
    .wrn                        (wrn            ),
    .rdn                        (rdn            ),

    //// inout ////
    .data_lcd                   (data_lcd       )

    ) ;  // cmd2lcd

pat_update pat_update(
  ////  SYSTEM  ////
    //// input ////
    .clk                        (clk          ),
    .rst_n                      (rst_n        ),
    .trigger_33ms               (trigger_33ms ),

  ////  ADC(touch)  ////
    //// output ////
    .adc_dclk                   (adc_clk      ),
    .adc_cs_n                   (adc_cs_n     ),
    .adc_data_to                (adc_data_to  ),

    //// input ////
    .adc_busy                   (adc_busy     ),
    .adc_data_from              (adc_data_from),
    .adc_penint_n               (adc_penint   ),

  ////  RAM  ////
    //// output ////
    .frame_upd_start            (frame_upd_start ),  // m-s 20140923(1)
    .single_upd_start           (single_upd_start),
    .x_coordinate               (x_coordinate    ),
    .y_coordinate               (y_coordinate    ),
    .write_enb                  (buf_data_valid  ),
    .data_buff                  (buf_data        ),

    //// input ////
    .frame_end                  (frame_update    ),
    .sleep_off                  (sleep_off       ),  // a- 20140925(1)
    .write_enb_ack              (buf_data_ack    )  // m-e 20140923(1)
    
    ) ;  // pat_update

display display(
  ////  SYSTEM  ////
    //// output ////
    .frame_update               (frame_update   ),

    //// input ////
    .clk                        (clk            ),
    .rst_n                      (rst_n          ),
    .trigger_33ms               (trigger_33ms   ),
    
  ////  BUFF_CTRL  ////
    //// output ////
    .sleep_off                  (sleep_off       ),  // a- 20140925(1)
    .data_bvld_ack              (buf_data_ack    ),  // m- 20140923(1)

    //// input ////
    .frame_upd_start            (frame_upd_start ),  // m-6 20140923(1)
    .single_upd_start           (single_upd_start),
    .x_coordinate               (x_coordinate    ),
    .y_coordinate               (y_coordinate    ),
    .data_buf_valid             (buf_data_valid  ),
    .data_buff                  (buf_data        ),
    
  ////  CMD2LCD  ////
    //// output ////
    .cmd_valid                  (lcd_cmd_valid  ),
    .cmd                        (lcd_cmd        ),
    .read_cmd_enb               (lcd_rcmd_enb   ),
    .cmd_cycle                  (lcd_cmd_cycle  ),
    .data_wr_valid              (lcd_wdata_valid),
    .data_wr                    (lcd_wdata      ),
    .ack_rd                     (lcd_read_ack   ),

    //// input ////
    .ack_wr                     (lcd_write_ack  ),
    .data_rd_valid              (lcd_rdata_valid),
    .data_rd                    (lcd_rdata      ),
    .cmd_finish                 (lcd_cmd_finish ),
    .wrphase_finish             (lcd_wrphase_finish)  // m- 20140923(1)
    
    ) ;  // display

timer timer(
  ////  SYSTEM  ////
    //// output ////
    .trigger_33ms               (trigger_33ms),

    //// input ////
    .clk                        (clk         ),
    .rst_n                      (rst_n       )
    
    ) ;  // timer


endmodule  // lt24_display


