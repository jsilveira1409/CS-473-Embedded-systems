////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    File name    : cmd2lcd.v                                                //
//    Version      : V1.0                                                     //
//    Author       : Fang                                                     //
//    Create Date  : 2014.07.22                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//              cmd2lcd overview                                              //
//  This cmd2lcd module is used to output signals to LT24 LCD module.         //
//  Recieve Write/Read commands, then change to LT24 MCU interface.           //
////////////////////////////////////////////////////////////////////////////////
//    History :                                                               //
//  20140722 :                                                                //
//    1. New Create. by Fang                                                  //
//  20140923 :                                                                //
//    1. Modify, remove RAM and re-design. by Fang                            //
////////////////////////////////////////////////////////////////////////////////

module cmd2lcd (
  ////  SYSTEM  ////
    //// input ////
    clk,
    rst_n,

  ////  LT24_Command  ////
    //// output ////
    data_rd_valid,
    data_rd,
    ack_wr,
    cmd_finish,
    wrphase_finish,

    //// input ////
    cmd_valid,
    cmd,
    read_enb,
    cmd_cycle,
    data_wr_valid,
    data_wr,
    ack_rd,

  ////  LT24  ////
    //// output ////
    csn,
    data_cmdn,
    wrn,
    rdn,

    //// inout ////
    data_lcd

    ) ;  // cmd2lcd

  ////  LT24  ////
    output csn ;
    output data_cmdn ;
    output wrn ;
    output rdn ;
    inout [15:0] data_lcd ;

    reg csn ;
    reg data_cmdn ;
    reg wrn ;
    reg rdn ;
    wire [15:0] data_lcd ;

  ////  LT24_Command  ////
    input cmd_valid ;
    input [7:0] cmd ;
    input read_enb ;
    input [15:0] cmd_cycle ;
    input data_wr_valid ;
    input [15:0] data_wr ;
    input ack_rd ;

    wire [7:0] cmd ;
    wire [15:0] cmd_cycle ;
    wire [15:0] data_wr ;

    output data_rd_valid ;
    output [15:0] data_rd ;
    output ack_wr ;
    output cmd_finish ;
    output wrphase_finish ;  // m- 20140923(1)

    reg data_rd_valid ;
    reg [15:0] data_rd ;
    reg ack_wr ;
    reg cmd_finish ;
    reg wrphase_finish ;  // m- 20140923(1)

  ////  SYSTEM  ////
    input clk ;
    input rst_n ;
    

////////////////  define parameter  ////////////////////////////////////////////
parameter W_HIGH_END          = 8'd2  ;  // wrn pulse H duration counter end point.
parameter W_LOW_END           = 8'd2  ;  // wrn pulse L duration counter end point.
parameter R_HIGH_END          = 8'd5  ;  // rdn(ID) pulse H duration counter end point.
parameter R_LOW_END           = 8'd3  ;  // rdn(ID) pulse L duration counter end point.
parameter RFM_HIGH_END        = 8'd5  ;  // rdn(FM) pulse H duration counter end point.
parameter RFM_LOW_END         = 8'd18 ;  // rdn(FM) pulse L duration counter end point.

////////////////  c2l_sta FSM parameter  ////////////////////////////////////////
parameter C2L_IDLE             = 4'b0000 ;  // 0; c2l_sta idle.
parameter C2L_CMD_PH           = 4'b0001 ;  // 1; command phase.
parameter C2L_WAIT_VALID       = 4'b0011 ;  // 3; wait valid signals.
parameter C2L_WRITE_DATA       = 4'b0111 ;  // 7; write data state.
parameter C2L_WAIT_WR_VALID    = 4'b0101 ;  // 5; wait "data_wr_valid" signal.
parameter C2L_READ_INVALID     = 4'b1011 ;  //11; read data state
parameter C2L_READ_DATA        = 4'b1001 ;  // 9; read data state
parameter C2L_WAIT_RD_VALID    = 4'b1000 ;  // 8; wait "data_rd_valid" signal.
parameter C2L_FINISH           = 4'b0010 ;  // 2; c2l_sta finish state.
////////////////  c2l_sta FSM parameter end  ////////////////////////////////////
////////////////  define parameter end  ////////////////////////////////////////

////////////////  internal wire and registers  /////////////////////////////////
    reg [3:0] c2l_sta, c2l_nxt ;

    reg read_finish ;
    reg fm_access ;
    reg [7:0] high_cnt ;
    reg [7:0] low_cnt ;
    reg [15:0] cycle_cnt ;
    reg data_lcd_oe ;
    reg [15:0] data_lcd_out ;
    reg write_finish ;  // a- 20140923(1)

////////////////  internal wire and registers end  /////////////////////////////

////////////////  internal signals  ////////////////////////////////////////////
  ////////  write_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140923(1)
    begin
      if (!rst_n)
        write_finish <= 1'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH :
            begin
              if (high_cnt == W_HIGH_END)
                write_finish <= 1'b1 ;
              else
                write_finish <= 1'b0 ;
            end
          C2L_WRITE_DATA :
            begin
              if (high_cnt == W_HIGH_END)
                write_finish <= 1'b1 ;
              else
                write_finish <= 1'b0 ;
            end
          default : write_finish <= 1'b0 ;
        endcase  // c2l_sta
    end
  ////////  write_finish signal end ////////////////

  ////////  read_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        read_finish <= 1'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_READ_INVALID,
          C2L_READ_DATA :
            begin
              if (high_cnt == W_HIGH_END)
                read_finish <= 1'b1 ;
              else
                read_finish <= 1'b0 ;
            end
          default : read_finish <= 1'b0 ;
        endcase  // c2l_sta
    end
  ////////  read_finish signal end ////////////////

  ////////  fm_access signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        fm_access <= 1'b0 ;
      else
        if (c2l_sta == C2L_FINISH)
          fm_access <= 1'b0 ;
        else
          if (cmd_valid)
            case(cmd)  // synopsys parallel_case
              8'h2E,
              8'h3E :  fm_access <= 1'b1 ;
              default : fm_access <= 1'b0 ;
            endcase  // cmd
          else
            fm_access <= fm_access ;
    end
  ////////  fm_access signal end ////////////////

  ////////  high_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        high_cnt <= 'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH,
          C2L_WRITE_DATA :
            begin
              if (write_finish)
                high_cnt <= 'b0 ;
              else
                if (low_cnt == W_LOW_END)
                  high_cnt <= high_cnt + 1'b1 ;
                else
                  high_cnt <= 'b0 ;
            end
          C2L_READ_INVALID,
          C2L_READ_DATA :
            begin
              if (read_finish)
                high_cnt <= 'b0 ;
              else
                if ((fm_access && (low_cnt == RFM_LOW_END)) ||
                    (!fm_access && (low_cnt == R_LOW_END))
                   )
                  high_cnt <= high_cnt + 1'b1 ;
                else
                  high_cnt <= 'b0 ;
            end
          default : high_cnt <= 'b0 ;
        endcase  //c2l_sta
    end
  ////////  high_cnt bus end  ////////////////

  ////////  low_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        low_cnt <= 'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_IDLE :
            begin
              if (cmd_valid)
                low_cnt <= 8'h01 ;
              else
                low_cnt <= 'b0 ;
            end
          C2L_CMD_PH,
          C2L_WRITE_DATA :
            begin
              if (write_finish)
                low_cnt <= 'b0 ;
              else
                if (low_cnt == W_LOW_END)
                  low_cnt <= low_cnt ;
                else
                  low_cnt <= low_cnt + 1'b1 ;
            end
          C2L_WAIT_VALID :
            begin
              if (data_wr_valid || read_enb)
                low_cnt <= 8'h01 ;
              else
                low_cnt <= 'b0 ;
            end
          C2L_WAIT_WR_VALID :
            begin
              if (data_wr_valid)
                low_cnt <= 8'h01 ;
              else
                low_cnt <= 'b0 ;
            end
          C2L_READ_INVALID,
          C2L_READ_DATA :
            begin
              if (read_finish)
                low_cnt <= 'b0 ;
              else
                if ((fm_access && (low_cnt == RFM_LOW_END)) ||
                    (!fm_access && (low_cnt == R_LOW_END))
                   )
                  low_cnt <= low_cnt ;
                else
                  low_cnt <= low_cnt + 1'b1 ;
            end
          C2L_WAIT_RD_VALID :
            begin
              if (!data_rd_valid)
                low_cnt <= 8'h01 ;
              else
                low_cnt <= 'b0 ;
            end
          default : low_cnt <= 'b0 ;
        endcase  //c2l_sta
    end
  ////////  low_cnt bus end  ////////////////

  ////////  cycle_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cycle_cnt <= 'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_IDLE : cycle_cnt <= 'b0 ;
          C2L_CMD_PH :
            begin
              if (write_finish)
                cycle_cnt <= cycle_cnt + 1'b1 ;
              else
                cycle_cnt <= cycle_cnt ;
            end
          C2L_WRITE_DATA :
            begin
              if (write_finish)
                if (cycle_cnt == 16'hffff)
                  cycle_cnt <= cycle_cnt ;
                else
                  cycle_cnt <= cycle_cnt + 1'b1 ;
              else
                cycle_cnt <= cycle_cnt ;
            end
          C2L_READ_DATA :
            begin
              if (read_finish)
                if (cycle_cnt == 16'hffff)
                  cycle_cnt <= cycle_cnt ;
                else
                  cycle_cnt <= cycle_cnt + 1'b1 ;
              else
                cycle_cnt <= cycle_cnt ;
            end
          C2L_WAIT_WR_VALID,
          C2L_WAIT_RD_VALID :
            begin
              if (cmd_valid)
                cycle_cnt <= 'b0 ;
              else
                cycle_cnt <= cycle_cnt ;
            end
          default : cycle_cnt <= cycle_cnt ;
        endcase  //c2l_sta
    end
  ////////  cycle_cnt bus end  ////////////////

  ////////  data_lcd_oe signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_lcd_oe <= 1'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH : data_lcd_oe <= 1'b1 ;
          C2L_WRITE_DATA :
            begin
              if (write_finish)
                data_lcd_oe <= 1'b0 ;
              else
                data_lcd_oe <= 1'b1 ;
            end
          default : data_lcd_oe <= 1'b0 ;
        endcase  // c2l_sta
    end
  ////////  data_lcd_oe signal end ////////////////

  ////////  data_lcd_out bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_lcd_out <= 16'h0000 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH : data_lcd_out <= {8'h00, cmd[7:0]} ;
          C2L_WRITE_DATA : data_lcd_out <= data_wr ;
          default : data_lcd_out <= 16'h0000 ;
        endcase  // c2l_sta
    end
  ////////  data_lcd_out bus end ////////////////
////////////////  internal signals end  ////////////////////////////////////////


////////////////  c2l_sta FSM  /////////////////////////////////////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        c2l_sta <= C2L_IDLE ;
      else
        c2l_sta <= c2l_nxt ;
    end

  always @(*)
    begin
      case(c2l_sta)  // synopsys parallel_case
        C2L_IDLE :
          begin
            if (cmd_valid)
              c2l_nxt = C2L_CMD_PH ;
            else
              c2l_nxt = C2L_IDLE ;
          end
        C2L_CMD_PH :
          begin
            if (write_finish)
              c2l_nxt = C2L_WAIT_VALID ;
            else
              c2l_nxt = C2L_CMD_PH ;
          end
        C2L_WAIT_VALID :
          begin
            if (cmd_cycle == 'b1)
              c2l_nxt = C2L_FINISH ;
            else
              if (read_enb)
                c2l_nxt = C2L_READ_INVALID ;
              else
                if (data_wr_valid)
                  c2l_nxt = C2L_WRITE_DATA ;
                else
                  c2l_nxt = C2L_WAIT_VALID ;
          end
        C2L_WRITE_DATA :
          begin
            if (write_finish)
              c2l_nxt = C2L_WAIT_WR_VALID ;
            else
              c2l_nxt = C2L_WRITE_DATA ;
          end
        C2L_WAIT_WR_VALID :
          begin
            if (cycle_cnt == cmd_cycle)
              c2l_nxt = C2L_FINISH ;
            else
              if (cmd_valid)
                c2l_nxt = C2L_CMD_PH ;
              else
                if (data_wr_valid)
                  c2l_nxt = C2L_WRITE_DATA ;
                else
                  c2l_nxt = C2L_WAIT_WR_VALID ;
          end
        C2L_READ_INVALID :
          begin
            if (read_finish)
              c2l_nxt = C2L_WAIT_RD_VALID ;
            else
              c2l_nxt = C2L_READ_INVALID ;
          end
        C2L_READ_DATA :
          begin
            if (read_finish)
              c2l_nxt = C2L_WAIT_RD_VALID ;
            else
              c2l_nxt = C2L_READ_DATA ;
          end
        C2L_WAIT_RD_VALID :
          begin
            if (cycle_cnt == cmd_cycle)
              c2l_nxt = C2L_FINISH ;
            else
              if (cmd_valid)
                c2l_nxt = C2L_CMD_PH ;
              else
                if (!data_rd_valid)
                  c2l_nxt = C2L_READ_DATA ;
                else
                  c2l_nxt = C2L_WAIT_RD_VALID ;
          end
        C2L_FINISH : c2l_nxt = C2L_IDLE ;
       default : c2l_nxt = C2L_IDLE ;
      endcase  // c2l_sta
    end
////////////////  c2l_sta FSM  /////////////////////////////////////////////////

////////////////  LT24_Command output  /////////////////////////////////////////
  ////////  data_rd_valid signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_rd_valid <= 1'b0 ;
      else
        if (ack_rd)
          data_rd_valid <= 1'b0 ;
        else
          if ((c2l_sta == C2L_READ_DATA) && (high_cnt == 8'h0) &&
              ((fm_access && (low_cnt == RFM_LOW_END)) ||
               (!fm_access && (low_cnt == R_LOW_END))
              )
             )
            data_rd_valid <= 1'b1 ;
          else
            data_rd_valid <= data_rd_valid ;
    end
  ////////  data_rd_valid signal end ////////////////

  ////////  data_rd bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_rd <= 'b0 ;
      else
        if (ack_rd)
          data_rd <= 1'b0 ;
        else
          if ((c2l_sta == C2L_READ_DATA) && (high_cnt == 8'h0) &&
              ((fm_access && (low_cnt == RFM_LOW_END)) ||
               (!fm_access && (low_cnt == R_LOW_END))
              )
             )
            data_rd <= data_lcd ;
          else
            data_rd <= data_rd ;
    end
  ////////  data_rd bus end ////////////////

  ////////  ack_wr signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        ack_wr <= 1'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_WRITE_DATA :
            begin
              if ((low_cnt == W_LOW_END) && !wrn)
                ack_wr <= 1'b1 ;
              else
                ack_wr <= 1'b0 ;
            end
          default : ack_wr <= 1'b0 ;
        endcase  // c2l_sta
    end
  ////////  ack_wr signal end ////////////////

  ////////  cmd_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd_finish <= 1'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_FINISH : cmd_finish <= 1'b1 ;
          default : cmd_finish <= 1'b0 ;
        endcase  // c2l_sta
    end
  ////////  cmd_finish signal end ////////////////

  ////////  wrphase_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)    // m- 20140923(1)
    begin
      if (!rst_n)
        wrphase_finish <= 1'b0 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_WRITE_DATA :
            begin
              if (high_cnt == W_HIGH_END)
                wrphase_finish <= 1'b1 ;
              else
                wrphase_finish <= 1'b0 ;
            end
          default : wrphase_finish <= 1'b0 ;
        endcase  // c2l_sta
    end
  ////////  wrphase_finish signal end ////////////////
////////////////  LT24_Command output end //////////////////////////////////////

////////////////  LT24 output  /////////////////////////////////////////////////
  ////////  csn signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        csn <= 1'b1 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH : csn <= 1'b0 ;
          C2L_FINISH : csn <= 1'b1 ;
          default : csn <= csn ;
        endcase  // c2l_sta
    end
  ////////  csn signal end ////////////////

  ////////  data_cmdn signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_cmdn <= 1'b1 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH : data_cmdn <= 1'b0 ;
          default : data_cmdn <= 1'b1 ;
        endcase  // c2l_sta
    end
  ////////  data_cmdn signal end ////////////////

  ////////  wrn signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        wrn <= 1'b1 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_CMD_PH,
          C2L_WRITE_DATA :
            begin
              if (low_cnt == W_LOW_END)
                wrn <= 1'b1 ;
              else
                wrn <= 1'b0 ;
            end
          default : wrn <= 1'b1 ;
        endcase  // c2l_sta
    end
  ////////  wrn signal end ////////////////

  ////////  rdn signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        rdn <= 1'b1 ;
      else
        case(c2l_sta)  // synopsys parallel_case
          C2L_READ_INVALID,
          C2L_READ_DATA :
            begin
              if ((fm_access && (low_cnt == RFM_LOW_END)) ||
                  (!fm_access && (low_cnt == R_LOW_END))
                 )
                rdn <= 1'b1 ;
              else
                rdn <= 1'b0 ;
            end
          default : rdn <= 1'b1 ;
        endcase  // c2l_sta
    end
  ////////  rdn signal end ////////////////

  ////////  data_lcd bus  ////////////////
  assign data_lcd = data_lcd_oe ? data_lcd_out : 16'hzzzz ;
  ////////  data_lcd bus end ////////////////
////////////////  LT24 output end //////////////////////////////////////////////

endmodule  // cmd2lcd

