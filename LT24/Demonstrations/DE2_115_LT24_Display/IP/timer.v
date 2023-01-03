////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    File name    : timer.v                                                  //
//    Version      : V1.0                                                     //
//    Author       : Fang                                                     //
//    Create Date  : 2014.09.05                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//              timer overview                                                //
//  This timer module is timer mocule to generate 1T width pulse and 33ms     //
//  cycle signal -- trigger_33ms.                                             //
////////////////////////////////////////////////////////////////////////////////
//    History :                                                               //
//  20140904 :                                                                //
//    1. New Create. by Fang                                                  //
////////////////////////////////////////////////////////////////////////////////

module timer (
  ////  SYSTEM  ////
    //// output ////
    trigger_33ms,

    //// input ////
    clk,
    rst_n
    
    ) ;  // timer

  ////  SYSTEM  ////
    input clk ;
    input rst_n ;
    
    output trigger_33ms ;

    reg trigger_33ms ;

////////////////  timer parameter  /////////////////////////////////////////////
`ifdef SIM
parameter  COUNT_33MS_END               = 16'h004C ;
`else
parameter  COUNT_33MS_END               = 16'h0CE4 ;
`endif
////////////////  timer parameter  /////////////////////////////////////////////

////////////////  internal wire and registers  /////////////////////////////////
    wire clk_100khz ;
    wire clk100khz_lock ;
    
////////////////  clk_domain  ////////////////
    reg cycle_33ms ;
    reg cycle_33ms_dly ;
////////////////  clk_domain end  ////////////////

////////////////  100KHZ_domain  ////////////////
    reg [15:0] count_33ms ;
////////////////  100KHZ_domain end  ////////////////
////////////////  internal wire and registers end  /////////////////////////////

////////////////  internal signals  ////////////////////////////////////////////
////////////////  clk_domain  ////////////////
  ////////  cycle_33ms signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cycle_33ms <= 1'b0 ;
      else
        if (count_33ms == COUNT_33MS_END)
          cycle_33ms <= 1'b1 ;
        else
          cycle_33ms <= 1'b0 ;
    end
  ////////  cycle_33ms signal end  ////////////////

  ////////  cycle_33ms_dly signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cycle_33ms_dly <= 1'b0 ;
      else
        cycle_33ms_dly <= cycle_33ms ;
    end
  ////////  cycle_33ms_dly signal end  ////////////////
////////////////  clk_domain end  ////////////////

////////////////  100KHZ_domain  ////////////////
  ////////  count_33ms bus  ////////////////
//  always @(posedge clk or negedge rst_n)
  always @(posedge clk_100khz or negedge clk100khz_lock)
    begin
      if (!clk100khz_lock)
        count_33ms <= 'b0 ;
      else
        if (count_33ms == COUNT_33MS_END)
          count_33ms <= 'b0 ;
        else
          count_33ms <= count_33ms + 1'b1 ;
    end
  ////////  count_33ms bus end  ////////////////
////////////////  100KHZ_domain end  ////////////////
////////////////  internal signals end  ////////////////////////////////////////

pll_50M_to_100K pll_50M_to_100K(
	.areset(!rst_n),
	.inclk0(clk),
	.c0(clk_100khz),
	.locked(clk100khz_lock));

////////////////  SYSTEM output  ///////////////////////////////////////////////
  ////////  trigger_33ms signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        trigger_33ms <= 1'b0 ;
      else
        if (cycle_33ms && !cycle_33ms_dly)
          trigger_33ms <= 1'b1 ;
        else
          trigger_33ms <= 1'b0 ;
    end
  ////////  trigger_33ms signal end ////////////////
////////////////  SYSTEM output end ////////////////////////////////////////////

endmodule  // timer

