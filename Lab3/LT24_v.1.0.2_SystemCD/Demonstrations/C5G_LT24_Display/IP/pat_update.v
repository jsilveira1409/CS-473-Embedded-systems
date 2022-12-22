////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    File name    : pat_update.v                                             //
//    Version      : V1.0                                                     //
//    Author       : Fang                                                     //
//    Create Date  : 2014.08.28                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//              pat_update overview                                           //
//  This pat_update module is used to update frame data. The update moment has//
//  two : initial and pen_interrupt.                                          //
////////////////////////////////////////////////////////////////////////////////
//    History :                                                               //
//  20140828 :                                                                //
//    1. New Create. by Fang                                                  //
//  20140916 :                                                                //
//    1. Add, add pat_enb function & modify FSM. by Fang                      //
//  20140917 :                                                                //
//    1. Modify, fix bugs found by normal_test_2 pattern. by Fang             //
//            adc_data_to & adc_dclk timing is non-match SPEC;                //
//            channel_sel wrong value in the first time of "PAT_SET_X_CTRL";  //
//            write_enb output condition was wrong;                           //
//            x_calculate & y_calculate lated 1T.                             //
//  20140923 :                                                                //
//    1. Modify, remove RAM and re-design. by Fang                            //
//  20140925 :                                                                //
//    1. Add, add adc_initial function. by Fang                               //
//  20140926 :                                                                //
//    1. Modify, modify adc_dclk is 5MHz. by Fang                             //
//  20140930 :                                                                //
//    1. Modify, tune touch interface for correct access and work with LCD.   //
//    2. Add, add clear function. by Fang                                     //
//    3. Add, sometime pat_sta state machine was crash after PAT_WT_PENINT    //
//            state, fixed by input signal adc_penint_n was synchronized. Fang//
////////////////////////////////////////////////////////////////////////////////

module pat_update (
  ////  SYSTEM  ////
    //// input ////
    clk,
    rst_n,
    trigger_33ms,
    
  ////  ADC(touch)  ////
    //// output ////
    adc_dclk,
    adc_cs_n,
    adc_data_to,

    //// input ////
    adc_busy,
    adc_data_from,
    adc_penint_n,
    
  ////  RAM  ////
    //// output ////
    frame_upd_start,
    single_upd_start,
    x_coordinate,
    y_coordinate,
    write_enb,
    data_buff,

    //// input ////
    frame_end,
    sleep_off,
    write_enb_ack
    
    ) ;  // pat_update

  ////  RAM  ////
    input frame_end ;  // a-2 20140923(1)
    input write_enb_ack ;
    input sleep_off ;  // a- 20140925

    output frame_upd_start ;  // a-4 20140923(1)
    output single_upd_start ;
    output [8:0] x_coordinate ;
    output [8:0] y_coordinate ;
    output write_enb ;
    output [15:0] data_buff ;
    
    reg frame_upd_start ;  // a-2 20140923(1)
    reg single_upd_start ;
    reg write_enb ;
    reg [15:0] data_buff ;
    
  ////  ADC(touch)  ////
    input adc_busy ;
    input adc_data_from ;
    input adc_penint_n ;
    
    output adc_dclk ;
    output adc_cs_n ;
    output adc_data_to ;

    reg adc_dclk ;
    reg adc_cs_n ;
    reg adc_data_to ;

  ////  SYSTEM  ////
    input clk ;
    input rst_n ;
    input trigger_33ms ;
    
////////////////  pat_update parameter  ////////////////////////////////////////
`ifdef SIM
parameter  UPD_STR_CNT_END               = 6'h01 ;
`else
parameter  UPD_STR_CNT_END               = 6'h20 ;
`endif
////////////////  pat_update parameter  ////////////////////////////////////////

////////////////  pat_sta FSM parameter  ///////////////////////////////////////
parameter PAT_IDLE             = 5'b00000 ;  // 0; pat_sta idle
parameter PAT_R_PAT_S          = 5'b00001 ;  // 1; R-color pattern start
parameter PAT_R_PAT            = 5'b00010 ;  // 2; R-color pattern
parameter PAT_R_PAT_F          = 5'b00011 ;  // 3; R-color pattern Finish
parameter PAT_R_CHK_INI        = 5'b00100 ;  // 4; R-color Check Initial
parameter PAT_G_PAT_S          = 5'b00101 ;  // 5; G-color pattern start
parameter PAT_G_PAT            = 5'b00110 ;  // 6; G-color pattern
parameter PAT_G_PAT_F          = 5'b00111 ;  // 7; G-color pattern Finish
parameter PAT_G_CHK_INI        = 5'b01000 ;  // 8; G-color Check Initial
parameter PAT_B_PAT_S          = 5'b01001 ;  // 9; B-color pattern start
parameter PAT_B_PAT            = 5'b01010 ;  // a; B-color pattern
parameter PAT_B_PAT_F          = 5'b01011 ;  // b; B-color pattern Finish
parameter PAT_INI_F            = 5'b01100 ;  // c; Initial Finish
parameter PAT_WT_PENINT        = 5'b01101 ;  // d; Wait Pen-interrupt
parameter PAT_SET_X_CTRL       = 5'b01110 ;  // e; Set X control
parameter PAT_REC_X_COOR       = 5'b01111 ;  // f; Recieve X-coordinate
parameter PAT_SET_Y_CTRL       = 5'b10000 ;  //10; Set Y control
parameter PAT_REC_Y_COOR       = 5'b10001 ;  //11; Recieve Y-coordinate
parameter PAT_CAL_ADDR         = 5'b10010 ;  //12; Calculate Address
parameter PAT_WR_RAM           = 5'b10011 ;  //13; Write to RAM
////////////////  pat_sta FSM parameter end  ///////////////////////////////////

////////////////  internal wire and registers  /////////////////////////////////
    reg [4:0] pat_sta, pat_nxt ;

    reg update_start ;
    reg [5:0] upd_str_cnt ;  // update_start count
    reg initial_enb ;
    reg dclk_enb ;
    reg [4:0] dclk_cnt ;
    reg [11:0] x_parameter ;
    reg [11:0] y_parameter ;
    reg [11:0] shift_in ;
    reg [7:0] shift_out ;
    reg [2:0] channel_sel ;
    reg [1:0] power_mgm ;
    reg [20:0] x_calculate ;
    reg [20:0] y_calculate ;
    wire [8:0] x_coordinate ;
    wire [8:0] y_coordinate ;
    reg [16:0] cal_addr_wr ;
    reg pat_enb ;  // a-2 20140916(1)
    reg [15:0] common_cnt ;
    reg adc_penint ;  // m- 20140930(3)
    reg adc_initial ;
    reg dclk_chg ;  // a-2 20140926(1)
    reg [7:0] dclk_chg_cnt ;
    reg red_bg ;  // a-3 20140930(2)
    reg green_bg ;
    reg blue_bg ;
    wire [11:0] y_par_offset ;  // a-6 20140930(1)
    wire [19:0] y_par_mul ;
    wire [11:0] y_par ;
    wire [11:0] x_par_offset ;
    wire [19:0] x_par_mul ;
    wire [11:0] x_par ;

////////////////  internal wire and registers end  /////////////////////////////

////////////////  internal signals  ////////////////////////////////////////////
  ////////  red_bg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140930(2)
    begin
      if (!rst_n)
        red_bg <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_R_PAT_F :
            begin
              if (frame_end)
                red_bg <= 1'b1 ;
              else
                red_bg <= red_bg ;
              end
          PAT_G_PAT_F,
          PAT_B_PAT_F :
            begin
              if (frame_end)
                red_bg <= 1'b0 ;
              else
                red_bg <= red_bg ;
              end
          default : red_bg <= red_bg ;
        endcase  // pat_sta
    end
  ////////  red_bg signal end  ////////////////

  ////////  green_bg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140930(2)
    begin
      if (!rst_n)
        green_bg <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_G_PAT_F :
            begin
              if (frame_end)
                green_bg <= 1'b1 ;
              else
                green_bg <= green_bg ;
              end
          PAT_R_PAT_F,
          PAT_B_PAT_F :
            begin
              if (frame_end)
                green_bg <= 1'b0 ;
              else
                green_bg <= green_bg ;
              end
          default : green_bg <= green_bg ;
        endcase  // pat_sta
    end
  ////////  green_bg signal end  ////////////////

  ////////  blue_bg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140930(2)
    begin
      if (!rst_n)
        blue_bg <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_B_PAT_F :
            begin
              if (frame_end)
                blue_bg <= 1'b1 ;
              else
                blue_bg <= blue_bg ;
              end
          PAT_R_PAT_F,
          PAT_G_PAT_F :
            begin
              if (frame_end)
                blue_bg <= 1'b0 ;
              else
                blue_bg <= blue_bg ;
              end
          default : blue_bg <= blue_bg ;
        endcase  // pat_sta
    end
  ////////  blue_bg signal end  ////////////////

  ////////  dclk_chg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140926(1)
    begin
      if (!rst_n)
        dclk_chg <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_CAL_ADDR,
          PAT_SET_X_CTRL,
          PAT_REC_X_COOR,
          PAT_SET_Y_CTRL,
          PAT_REC_Y_COOR :
            begin
              if (dclk_chg_cnt == 8'hf0)  // m- 20140930(1)
                dclk_chg <= 1'b1 ;
              else
                dclk_chg <= 1'b0 ;
            end
          default : dclk_chg <= 1'b0 ;
        endcase  // pat_sta
    end
  ////////  dclk_chg signal end  ////////////////

  ////////  dclk_chg_cnt bus end  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140926(1)
    begin
      if (!rst_n)
        dclk_chg_cnt <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_CAL_ADDR,
          PAT_SET_X_CTRL,
          PAT_REC_X_COOR,
          PAT_SET_Y_CTRL,
          PAT_REC_Y_COOR :
            begin
              if (dclk_chg_cnt == 8'hf0)  // m- 20140930(1)
                dclk_chg_cnt <= 'b0 ;
              else
                dclk_chg_cnt <= dclk_chg_cnt + 1'b1 ;
            end
          default : dclk_chg_cnt <= 'b0 ;
        endcase  // pat_sta
    end
  ////////  dclk_chg_cnt bus end  ////////////////

  ////////  adc_penint signal  ////////////////
  always @(posedge clk or negedge rst_n)    // m- 20140930(3)
    begin
      if (!rst_n)
        adc_penint <= 1'b0 ;
      else
        adc_penint <= ~adc_penint_n ;
    end
  ////////  adc_penint signal end  ////////////////

  ////////  adc_initial signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140915(1)
    begin
      if (!rst_n)
        adc_initial <= 1'b0 ;
      else
        if ((pat_sta == PAT_INI_F) && initial_enb)
          adc_initial <= 1'b1 ;
        else
          if (pat_sta == PAT_WR_RAM)  // a-3 20140930(1)
            adc_initial <= 1'b0 ;
          else
            adc_initial <= adc_initial ;  // m- 20140930(1)
    end
  ////////  adc_initial signal end  ////////////////

  ////////  pat_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140916(1)
    begin
      if (!rst_n)
        pat_enb <= 1'b0 ;
      else
        if ((pat_sta == PAT_IDLE) && (common_cnt == 16'h0080) && sleep_off)  // m- 20140925
          pat_enb <= 1'b1 ;
        else
          pat_enb <= pat_enb ;
    end
  ////////  pat_enb signal end  ////////////////

  ////////  common_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140916(1)
    begin
      if (!rst_n)
        common_cnt <= 'b0 ;
      else
        if (pat_sta == PAT_IDLE)
          common_cnt <= common_cnt + 1'b1 ;
        else
          common_cnt <= 'b0 ;
    end
  ////////  common_cnt bus end  ////////////////

  ////////  update_start signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        update_start <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_R_PAT_S :
            begin
              if (!initial_enb || 
                  (initial_enb && (upd_str_cnt == 6'h04))
                 )
                update_start <= 1'b1 ;
              else
                update_start <= 1'b0 ;
            end
          PAT_G_PAT_S,
          PAT_B_PAT_S :
            begin
              if (!initial_enb || 
                  (initial_enb && (upd_str_cnt == UPD_STR_CNT_END))
                 )
                update_start <= 1'b1 ;
              else
                update_start <= 1'b0 ;
            end
          default : update_start <= 1'b0 ;
        endcase  // pat_sta
    end
  ////////  update_start signal end  ////////////////

  ////////  upd_str_cnt bus  ////////////////
  always @(posedge trigger_33ms or negedge rst_n)
    begin
      if (!rst_n)
        upd_str_cnt <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_R_PAT_S,
          PAT_G_PAT_S,
          PAT_B_PAT_S :
            begin
              if (initial_enb)
                upd_str_cnt <= upd_str_cnt + 1'b1 ;
              else
                upd_str_cnt <= 'b0 ;
            end
          default : upd_str_cnt <= 'b0 ;
        endcase  // pat_sta
    end
  ////////  upd_str_cnt bus end  ////////////////

  ////////  initial_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        initial_enb <= 1'b1 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_IDLE : initial_enb <= 1'b1 ;
          PAT_INI_F : initial_enb <= 'b0 ;
          default : initial_enb <= initial_enb ;
        endcase  // pat_sta
    end
  ////////  initial_enb signal end  ////////////////

  ////////  dclk_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        dclk_enb <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_SET_Y_CTRL,
          PAT_SET_X_CTRL :
            begin
              if ((dclk_cnt == 5'h01) && dclk_chg)  // m- 20140926(1)
                dclk_enb <= 1'b1 ;
              else
                if (adc_dclk && (dclk_cnt == 5'h08) && dclk_chg)  // m- 20140926(1)
                  dclk_enb <= 1'b0 ;
                else
                  dclk_enb <= dclk_enb ;
            end
          PAT_REC_Y_COOR,
          PAT_REC_X_COOR :
            begin
              if (((dclk_cnt == 5'h01) || (dclk_cnt == 5'h09)) && dclk_chg)  // m- 20140926(1)
                dclk_enb <= 1'b1 ;
              else
                if ((adc_dclk &&
                     ((dclk_cnt == 5'h08) || (dclk_cnt == 5'h10)) &&
                     dclk_chg
                    )
                   )  // m- 20140926(1)
                  dclk_enb <= 1'b0 ;
                else
                  dclk_enb <= dclk_enb ;
            end
          default : dclk_enb <= 1'b0 ;
        endcase  // pat_sta
    end
  ////////  dclk_enb signal end  ////////////////

  ////////  dclk_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        dclk_cnt <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_SET_Y_CTRL,
          PAT_SET_X_CTRL :
            begin
              if (dclk_enb && dclk_chg && adc_dclk)  // m- 20140926(1)
                if (dclk_cnt == 5'h08)
                  dclk_cnt <= 5'h01 ;
                else
                  dclk_cnt <= dclk_cnt + 1'b1 ;
              else
                dclk_cnt <= dclk_cnt ;
            end
          PAT_REC_Y_COOR,
          PAT_REC_X_COOR :
            begin
              if (dclk_enb && dclk_chg && adc_dclk)  // m- 20140926(1)
                if (dclk_cnt == 5'h10)
                  dclk_cnt <= 5'h01 ;
                else
                  dclk_cnt <= dclk_cnt + 1'b1 ;
              else
                dclk_cnt <= dclk_cnt ;
            end
          default : dclk_cnt <= 5'h01 ;
        endcase  // pat_sta
    end
  ////////  dclk_cnt bus end  ////////////////

  ////////  x_parameter bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        x_parameter <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_REC_X_COOR :
            begin
              if (dclk_enb && dclk_chg && adc_dclk && (dclk_cnt == 5'h0D))  // m- 20140926(1)
                x_parameter <= shift_in ;
              else
                x_parameter <= x_parameter ;
            end
          default : x_parameter <= x_parameter ;
        endcase  // pat_sta
    end
  ////////  x_parameter bus end  ////////////////

  ////////  y_parameter bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        y_parameter <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_REC_Y_COOR :
            begin
              if (dclk_enb && dclk_chg && adc_dclk && (dclk_cnt == 5'h0D))  // m- 20140926(1)
                y_parameter <= shift_in ;
              else
                y_parameter <= y_parameter ;
            end
          default : y_parameter <= y_parameter ;
        endcase  // pat_sta
    end
  ////////  y_parameter bus end  ////////////////

  ////////  shift_in bus  ////////////////
  always @(posedge adc_dclk or negedge rst_n)
    begin
      if (!rst_n)
        shift_in <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_REC_X_COOR,
          PAT_REC_Y_COOR :
            begin
              if (!adc_busy)
                shift_in <= {shift_in[10:0], adc_data_from} ;
              else
                shift_in <= shift_in ;
            end
          default : shift_in <= shift_in ;
        endcase  // pat_sta
    end
  ////////  shift_in bus end  ////////////////

  ////////  shift_out bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        shift_out <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_REC_X_COOR,
          PAT_WT_PENINT : shift_out <= {1'b1, channel_sel, 1'b0, 1'b0, power_mgm} ;  // set control register
  //// Control Regidter : {start(1b),channel_sel(3b), mode(1b), SE/DF(1b), power management(2b)}
          PAT_SET_X_CTRL,
          PAT_SET_Y_CTRL :
            begin
              if (adc_dclk && dclk_chg)  // m- 20140926(1)
                shift_out <= {shift_out[6:0], 1'b0} ;
              else
                shift_out <= shift_out ;
            end
          default : shift_out <= 'b0 ;
        endcase  // pat_sta
    end
  ////////  shift_out bus end  ////////////////

  ////////  channel_sel bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        channel_sel <= 3'b001 ;  // m- 20140925(1)
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_WT_PENINT : channel_sel <= 3'b001 ;  // a- 20140917(1)
          PAT_SET_X_CTRL :
            begin
              if (adc_dclk && (dclk_cnt == 5'h08) && dclk_chg)  // m- 20140926(1)
                channel_sel <= 3'b101 ;
              else
                channel_sel <= channel_sel ;
            end
          PAT_SET_Y_CTRL :
            begin
              if (adc_dclk && (dclk_cnt == 5'h08) && dclk_chg)  // m- 20140926(1)
                channel_sel <= 3'b001 ;
              else
                channel_sel <= channel_sel ;
            end
          default : channel_sel <= channel_sel ;
        endcase  // pat_sta
    end
  ////////  channel_sel bus end  ////////////////

  ////////  power_mgm bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        power_mgm <= 2'b11 ;  // m- 20140925(1)
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_WT_PENINT : power_mgm <= 2'b11 ;  // a- 20140917(1)
          PAT_SET_X_CTRL :
            begin
              if (adc_dclk && (dclk_cnt == 5'h08) && dclk_chg)  // m- 20140926(1)
                power_mgm <= 2'b10 ;
              else
                power_mgm <= power_mgm ;
            end
          PAT_SET_Y_CTRL :
            begin
              if (adc_dclk && (dclk_cnt == 5'h08) && dclk_chg)  // m- 20140926(1)
                power_mgm <= 3'b11 ;
              else
                power_mgm <= power_mgm ;
            end
          default : power_mgm <= power_mgm ;
        endcase  // pat_sta
    end
  ////////  power_mgm bus end  ////////////////

//// a-s 20140930(1)

  assign y_par_offset = y_parameter ;
  assign y_par_mul = y_par_offset * 37 ;
  assign y_par = y_par_offset + y_par_mul[19:8] ;

//// a-e 20140930(1)

  ////////  x_calculate bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        x_calculate <= 'b0 ;
      else
        if ((pat_sta == PAT_REC_Y_COOR) &&
            (adc_dclk && (dclk_cnt == 5'd16) && dclk_chg)  // m- 20140926(1)
           )  // m- 20140917(1)
          x_calculate <= y_par * 15 ;  // m- 20140930(1)
        else
          x_calculate <= x_calculate ;
    end
  ////////  x_calculate bus end  ////////////////

//// a-s 20140930(1)

    assign x_par_offset = x_parameter ;
    assign x_par_mul = x_par_offset * 64 ;
    assign x_par = x_par_offset + x_par_mul[19:8] ;  // x_par = x_parameter * 1.25

//// a-e 20140930(1)

  ////////  y_calculate bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        y_calculate <= 'b0 ;
      else
        if ((pat_sta == PAT_REC_Y_COOR) &&
            (adc_dclk && (dclk_cnt == 5'd16) && dclk_chg)
           )  // m- 20140926(1)
          y_calculate <= x_par * 20 ;  // m- 20140930(1)
        else
          y_calculate <= y_calculate ;
    end
  ////////  y_calculate bus end  ////////////////

  ////////  x_coordinate bus  ////////////////
  assign x_coordinate = 239 - x_calculate[16:8] ;  // = x_cal/256;  // m- 20140930(1)
  ////////  x_coordinate bus end  ////////////////
  
  ////////  y_coordinate bus  ////////////////
  assign y_coordinate = y_calculate[16:8] ;  // = y_cal/256
  ////////  y_coordinate bus end  ////////////////

  ////////  cal_addr_wr bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cal_addr_wr <= 'b0 ;
      else
        if (pat_sta == PAT_CAL_ADDR)
          cal_addr_wr <= x_coordinate+y_coordinate*240 ;
        else
          cal_addr_wr <= cal_addr_wr ;
    end
  ////////  cal_addr_wr bus end  ////////////////
////////////////  internal signals end  ////////////////////////////////////////

////////////////  pat_sta FSM  /////////////////////////////////////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        pat_sta <= PAT_IDLE ;
      else
        pat_sta <= pat_nxt ;
    end

  always @(*)
    begin
      case(pat_sta)  // synopsys parallel_case
        PAT_IDLE :    // m- 20140916(1)
          begin
            if (pat_enb)
              if (initial_enb)
                pat_nxt = PAT_R_PAT_S ;
              else
                pat_nxt = PAT_B_PAT_S ;
            else
              pat_nxt = PAT_IDLE ;
          end
        PAT_R_PAT_S :
          begin
            if (update_start)
              pat_nxt = PAT_R_PAT ;
            else
              pat_nxt = PAT_R_PAT_S ;
          end
        PAT_R_PAT : pat_nxt = PAT_R_PAT_F ;
        PAT_R_PAT_F :
          begin
            if (frame_end)  // m- 20140923(1)
              pat_nxt = PAT_R_CHK_INI ;
            else    // m- 20140923(1)
              if (write_enb && write_enb_ack)
                pat_nxt = PAT_R_PAT ;
              else
                pat_nxt = PAT_R_PAT_F ;
          end
        PAT_R_CHK_INI :
          begin
            if (initial_enb)
              pat_nxt = PAT_G_PAT_S ;
            else
              pat_nxt = PAT_WT_PENINT ;
          end
        PAT_G_PAT_S :
          begin
            if (update_start)
              pat_nxt = PAT_G_PAT ;
            else
              pat_nxt = PAT_G_PAT_S ;
          end
        PAT_G_PAT : pat_nxt = PAT_G_PAT_F ;
        PAT_G_PAT_F :
          begin
            if (frame_end)  // m- 20140923(1)
              pat_nxt = PAT_G_CHK_INI ;
            else    // m- 20140923(1)
              if (write_enb && write_enb_ack)
                pat_nxt = PAT_G_PAT ;
              else
                pat_nxt = PAT_G_PAT_F ;
          end
        PAT_G_CHK_INI :
          begin
            if (initial_enb)
              pat_nxt = PAT_B_PAT_S ;
            else
              pat_nxt = PAT_WT_PENINT ;
          end
        PAT_B_PAT_S :
          begin
            if (update_start)
              pat_nxt = PAT_B_PAT ;
            else
              pat_nxt = PAT_B_PAT_S ;
          end
        PAT_B_PAT : pat_nxt = PAT_B_PAT_F ;
        PAT_B_PAT_F :
          begin
            if (frame_end)  // m- 20140923(1)
              pat_nxt = PAT_INI_F ;
            else    // m- 20140923(1)
              if (write_enb && write_enb_ack)
                pat_nxt = PAT_B_PAT ;
              else
                pat_nxt = PAT_B_PAT_F ;
          end
        PAT_INI_F : pat_nxt = PAT_WT_PENINT ;
        PAT_WT_PENINT :
          begin
            if (adc_penint || adc_initial)  // m- 20140925(1)
              pat_nxt = PAT_SET_X_CTRL ;
            else
              pat_nxt = PAT_WT_PENINT ;
          end
        PAT_SET_X_CTRL :
          begin
            if (dclk_chg && adc_dclk && (dclk_cnt == 5'd8))  // m- 20140926(1)
              pat_nxt = PAT_REC_X_COOR ;
            else
              pat_nxt = PAT_SET_X_CTRL ;
          end
        PAT_REC_X_COOR :
          begin
            if (dclk_chg && adc_dclk && (dclk_cnt == 5'd16))  // m- 20140926(1)
              pat_nxt = PAT_SET_Y_CTRL ;
            else
              pat_nxt = PAT_REC_X_COOR ;
          end
        PAT_SET_Y_CTRL :
          begin
            if (dclk_chg && adc_dclk && (dclk_cnt == 5'd8))  // m- 20140926(1)
              pat_nxt = PAT_REC_Y_COOR ;
            else
              pat_nxt = PAT_SET_Y_CTRL ;
          end
        PAT_REC_Y_COOR :
          begin
            if (dclk_chg && adc_dclk && (dclk_cnt == 5'd16))  // m- 20140926(1)
              if (((x_parameter[11:8] == 4'h0) || (x_parameter[11:8] == 8'h1)) &&
                  (y_parameter[11:10] == 2'b11)
                 )    // a- 20140930(2)
                case({red_bg, green_bg, blue_bg})  // synopsys parallel_case
                  3'b001 : pat_nxt = PAT_B_PAT_S ;
                  3'b010 : pat_nxt = PAT_G_PAT_S ;
                  3'b100 : pat_nxt = PAT_R_PAT_S ;
                  default : pat_nxt = PAT_CAL_ADDR ;
                endcase
              else
                if (x_parameter[11:7] == 5'b1100_0)    // m- 20140930(2)
                  case(y_parameter[11:6])  // synopsys parallel_case
                    6'b1010_10 : pat_nxt = PAT_R_PAT_S ;
                    6'b0111_10 : pat_nxt = PAT_G_PAT_S ;
                    6'b0100_11 : pat_nxt = PAT_B_PAT_S ;
                    default : pat_nxt = PAT_CAL_ADDR ;
                  endcase  // y_parameter
                else
                  pat_nxt = PAT_CAL_ADDR ;
            else
              pat_nxt = PAT_REC_Y_COOR ;
          end
        PAT_CAL_ADDR :    // m- 20140926(1)
          begin
            if (dclk_chg)
              pat_nxt = PAT_WR_RAM ;
            else
              pat_nxt = PAT_CAL_ADDR ;
          end
        PAT_WR_RAM :    // m- 20140923(1)
          begin
            if (write_enb && write_enb_ack)
              pat_nxt = PAT_WT_PENINT ;
            else
              pat_nxt = PAT_WR_RAM ;
          end
        default : pat_nxt = PAT_IDLE ;
      endcase  // pat_sta
    end
////////////////  pat_sta FSM  /////////////////////////////////////////////////

////////////////  RAM output  //////////////////////////////////////////////////
  ////////  frame_upd_start signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140923(1)
    begin
      if (!rst_n)
        frame_upd_start <= 1'b0 ;
      else
        if (update_start &&
            ((pat_sta == PAT_R_PAT_S) ||
             (pat_sta == PAT_G_PAT_S) ||
             (pat_sta == PAT_B_PAT_S))
           )
          frame_upd_start <= 1'b1 ;
        else
          frame_upd_start <= 1'b0 ;
    end
  ////////  frame_upd_start signal end  ////////////////

  ////////  single_upd_start signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140923(1)
    begin
      if (!rst_n)
        single_upd_start <= 1'b0 ;
      else
        if ((pat_sta == PAT_WR_RAM) && !write_enb)
          single_upd_start <= 1'b1 ;
        else
          single_upd_start <= 1'b0 ;
    end
  ////////  single_upd_start signal end  ////////////////

  ////////  write_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        write_enb <= 1'b0 ;
      else
        if ((pat_sta == PAT_R_PAT) ||
            (pat_sta == PAT_G_PAT) ||
            (pat_sta == PAT_B_PAT) ||
            (pat_sta == PAT_WR_RAM)
           )  // m- 20140917(1)
          write_enb <= 1'b1 ;
        else    // m- 20140923(1)
          if (write_enb_ack || frame_end)
            write_enb <= 1'b0 ;
          else
            write_enb <= write_enb ;
    end
  ////////  write_enb signal end ////////////////

  ////////  data_buff bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_buff <= 'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_R_PAT : data_buff <= 16'h001F ;
          PAT_G_PAT : data_buff <= 16'h07E0 ;
          PAT_B_PAT : data_buff <= 16'hF800 ; 
          PAT_WR_RAM : data_buff <= 16'h0000 ;
          default : data_buff <= data_buff ;
        endcase  // pat_sta
    end
  ////////  data_buff bus end ////////////////
////////////////  RAM output end ///////////////////////////////////////////////

////////////////  ADC(touch) output  ///////////////////////////////////////////
  ////////  adc_cs_n signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        adc_cs_n <= 1'b1 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_WT_PENINT :
            begin
              if (adc_penint || adc_initial)  // m- 20140925(1)
                adc_cs_n <= 1'b0 ;
              else
                adc_cs_n <= adc_cs_n ;
            end
          PAT_SET_X_CTRL,
          PAT_REC_X_COOR,
          PAT_SET_Y_CTRL,
          PAT_REC_Y_COOR : adc_cs_n <= 1'b0 ;
          PAT_CAL_ADDR :    // a- 20140926(1)
            begin
              if (dclk_chg)
                adc_cs_n <= 1'b1 ;
              else
                adc_cs_n <= adc_cs_n ;
            end
          default : adc_cs_n <= 1'b1 ;
        endcase  // pat_sta
    end
  ////////  adc_cs_n signal end ////////////////

  ////////  adc_dclk signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        adc_dclk <= 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_SET_X_CTRL,
          PAT_SET_Y_CTRL :
            begin
              if (dclk_enb && dclk_chg)  // m- 20140926)
                adc_dclk <= ~adc_dclk ;
              else
                adc_dclk <= adc_dclk ;
            end
          PAT_REC_X_COOR,
          PAT_REC_Y_COOR :
            begin
              if (dclk_enb && dclk_chg)  // m- 20140926)
                adc_dclk <= ~adc_dclk ;
              else
                adc_dclk <= adc_dclk ;
            end
          default : adc_dclk <= 1'b0 ;
        endcase  // pat_sta
    end
  ////////  adc_dclk signal end ////////////////

  ////////  adc_data_to signal  ////////////////
  always @(*)  // m- 20140917(1)
    begin
      if (!rst_n)
        adc_data_to = 1'b0 ;
      else
        case(pat_sta)  // synopsys parallel_case
          PAT_SET_X_CTRL,
          PAT_SET_Y_CTRL : adc_data_to = shift_out[7] ;
          default : adc_data_to = 1'b0 ;
        endcase  // pat_sta
    end
  ////////  adc_data_to signal end ////////////////
////////////////  ADC(touch) output end ////////////////////////////////////////

endmodule  // pat_update


