////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//    File name    : display.v                                                //
//    Version      : V1.0                                                     //
//    Author       : Fang                                                     //
//    Create Date  : 2014.09.01                                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//              display overview                                              //
//  This display module is a command controller, is responsiblr for generated //
//  commands. The flow of commands is depend on initial or display function.  //
////////////////////////////////////////////////////////////////////////////////
//    History :                                                               //
//  20140901 :                                                                //
//    1. New Create. by Fang                                                  //
//  20140916 :                                                                //
//    1. Add display_enb & initial_enb signals(function). by Fang             //
//  20140917 :                                                                //
//    1. Modify, fix LUT's value. by Fang                                     //
//  20140922 :                                                                //
//    1. Modify, modify include file path. by Fang                            //
//  20140923 :                                                                //
//    1. Modify, remove RAM and re-design. by Fang                            //
//  20140924 :                                                                //
//    1. Add, add PIXSET command. by Fang                                     //
//  20140925 :                                                                //
//    1. Add, add delay in the PCD_IDLE state. by Fang                        //
//    2. Add, add sleep_off. by Fang                                          //
//  20140926 :                                                                //
//    1. Modify, fix ec_addr bug when single_upd_start is active. by Fang     //
//  20140930 :                                                                //
//    1. Add, add R,G,B color in the Background. by Fang                      //
////////////////////////////////////////////////////////////////////////////////

module display (
  ////  SYSTEM  ////
    //// output ////
    frame_update,

    //// input ////
    clk,
    rst_n,
    trigger_33ms,
    
  ////  BUFF_CTRL  ////
    //// output ////
    sleep_off,
    data_bvld_ack,

    //// input ////
    frame_upd_start,
    single_upd_start,
    x_coordinate,
    y_coordinate,
    data_buf_valid,
    data_buff,
    
  ////  CMD2LCD  ////
    //// output ////
    cmd_valid,
    cmd,
    read_cmd_enb,
    cmd_cycle,
    data_wr_valid,
    data_wr,
    ack_rd,

    //// input ////
    ack_wr,
    data_rd_valid,
    data_rd,
    cmd_finish,
    wrphase_finish
    
    ) ;  // display

  ////  CMD2LCD  ////
    input ack_wr ;
    input data_rd_valid ;
    input [15:0] data_rd ;
    input cmd_finish ;
    input wrphase_finish ;  // m- 20140923(1)
    
    wire [15:0] data_rd ;
    
    output cmd_valid ;
    output [7:0] cmd ;
    output read_cmd_enb ;
    output [15:0] cmd_cycle ;
    output data_wr_valid ;
    output [15:0] data_wr ;
    output ack_rd ;

    reg cmd_valid ;
    reg [7:0] cmd ;
    reg read_cmd_enb ;
    reg [15:0] cmd_cycle ;
    reg data_wr_valid ;
    reg [15:0] data_wr ;
    reg ack_rd ;

  ////  BUFF_CTRL  ////
    input frame_upd_start ;  // a-4 20140923(1)
    input single_upd_start ;
    input [8:0] x_coordinate ;
    input [8:0] y_coordinate ;
    input data_buf_valid ;
    input [15:0] data_buff ;
    
    wire [15:0] data_buff ;
    
    output sleep_off ;  // a- 20140925(2)
    output data_bvld_ack ;

    reg sleep_off ;  // a- 20140925(2)
    reg data_bvld_ack ;

  ////  SYSTEM  ////
    input clk ;
    input rst_n ;
    input trigger_33ms ;

    output frame_update ;

    reg frame_update ;

////////////////  dpy_sta FSM parameter  ///////////////////////////////////////
parameter DPY_IDLE             = 5'b0_0000 ;  // 0; dpy_sta idle state
parameter DPY_CMD_START        = 5'b0_0001 ;  // 1; Command Start state
parameter DPY_WRITE_REG        = 5'b0_0010 ;  // 2; Write Register state
parameter DPY_PAR_OUT          = 5'b0_0011 ;  // 3; Parameter Output state
parameter DPY_CHK_OUTNUMB      = 5'b0_0100 ;  // 4; Check Output Number state
parameter DPY_WRITE_PAT        = 5'b0_0101 ;  // 5; Write Pattern state
parameter DPY_READ_BUFF        = 5'b0_0110 ;  // 6; Read Buffer data state
parameter DPY_CHK_BUFNUMB      = 5'b0_0111 ;  // 7; Check Buffer Number state
parameter DPY_NOP              = 5'b0_1000 ;  // 8; NOP command state
parameter DPY_WRITE_LUT        = 5'b0_1001 ;  // 9; Write LUT(Look Up Table) state
parameter DPY_READ_LUT         = 5'b0_1010 ;  // a; Read LUT data state
parameter DPY_CHK_LUTNUMB      = 5'b0_1011 ;  // b; Check LUT Number state
parameter DPY_READ_REG         = 5'b0_1100 ;  // c; Read register state
parameter DPY_PAR_IN           = 5'b0_1101 ;  // d; Parameter Input state
parameter DPY_CHK_INNUMB       = 5'b0_1110 ;  // e; Check Input Number state
parameter DPY_WAIT_FINISH      = 5'b0_1111 ;  // f; Wait Finish state
parameter DPY_FINISH           = 5'b1_0000 ;  //10; Finish state
////////////////  dpy_sta FSM parameter end  ///////////////////////////////////

////////////////  pcd_sta FSM parameter  ///////////////////////////////////////
parameter PCD_IDLE             = 4'b0000 ;  // 0; pcd_sta idle state
parameter PCD_PIXSET           = 4'b1100 ;  // c; PIXSET command
parameter PCD_SLPOUT           = 4'b0001 ;  // 1; SLPOUT command
parameter PCD_RDDSDR           = 4'b0010 ;  // 2; RDDSDR command
parameter PCD_CHK_RL_F         = 4'b0011 ;  // 3; Check Register Loading & Functionality bit
parameter PCD_RGBSET           = 4'b0100 ;  // 4; RGBSET command
parameter PCD_DISPON           = 4'b0101 ;  // 5; DISPON command
parameter PCD_WAIT_DELAY       = 4'b0110 ;  // 6; Wait 80ms delay sate
parameter PCD_DISP_IDLE        = 4'b0111 ;  // 7; display idle state
parameter PCD_CASET            = 4'b1000 ;  // 8; CASET command
parameter PCD_PASET            = 4'b1001 ;  // 9; PASET command
parameter PCD_RAMWR            = 4'b1010 ;  // a; RAMWR command
parameter PCD_FRAME_END        = 4'b1011 ;  // b; Read LUT data state
////////////////  pcd_sta FSM parameter end  ///////////////////////////////////

////////////////  LCD command parameter  ///////////////////////////////////////
`include "./lcd_cmd_par.inc"
//parameter CMD_NOP              = 8'h00 ;    // 0; LCD command -- NOP
//parameter CMD_SLPOUT           = 8'h11 ;    // 0; LCD command -- SLPOUT
//parameter CMD_RDDSDR           = 8'h0F ;    // 0; LCD command -- RDDSDR
//parameter CMD_DISPON           = 8'h29 ;    // 0; LCD command -- DISPON
//parameter CMD_CASET            = 8'h2A ;    // 0; LCD command -- CASET
//parameter CMD_PASET            = 8'h2B ;    // 0; LCD command -- PASET
//parameter CMD_RAMWR            = 8'h2C ;    // 0; LCD command -- RAMWR
//parameter CMD_RGBSET           = 8'h2D ;    // 0; LCD command -- RGBSET
////////////////  LCD command parameter end  ///////////////////////////////////

////////////////  internal wire and registers  /////////////////////////////////
    reg [4:0] dpy_sta, dpy_nxt ;
    reg [3:0] pcd_sta, pcd_nxt ;

////////////////  for pcd_sta  ////////////////
    reg cmd_start ;
    reg [7:0] cmd_reg ;
    reg [15:0] cmd_cycle_reg ;
    reg [7:0] par_enb_reg ;
    reg [15:0] par1_reg ;
    reg [15:0] par2_reg ;
    reg [15:0] par3_reg ;
    reg [15:0] par4_reg ;
    reg [15:0] par5_reg ;
    reg [15:0] par6_reg ;
    reg [15:0] par7_reg ;
    reg [15:0] par8_reg ;
    reg [7:0] frame_cnt ;  // frame count; count trigger_33ms
    reg disp_start ;
    reg [15:0] sc_addr ;  // start column address
    reg [15:0] ec_addr ;  // end column address
    reg [15:0] sp_addr ;  // start page address
    reg [15:0] ep_addr ;  // end page address
    reg rgbset_finish ;
    reg dispon_finish ;
    reg display_enb ;  // a-3 20140916(1)
    reg initial_enb ;
    reg [15:0] common_cnt ;
    reg frame_upd_keep ;  // a-2 20140923(1)
    reg single_upd_keep ;

////////////////  for dpy_sta  ////////////////
    reg dpy_cmd_finish ;
    reg [7:0] par_enb ;
    reg [15:0] par1 ;
    reg [15:0] par2 ;
    reg [15:0] par3 ;
    reg [15:0] par4 ;
    reg [15:0] par5 ;
    reg [15:0] par6 ;
    reg [15:0] par7 ;
    reg [15:0] par8 ;
    reg [15:0] cmd_cnt ;
    reg lut_read_enb ;
    reg [6:0] lut_addr_rd ;
    reg lut_data_valid ;
    reg [7:0] lut_data_buf ;
    reg rl_detect ;  // DSDR reg bit7
    reg func_detect ;  // DSDR reg bit6
    reg dsdr_latch ;  // DSDR register latch signal.
    reg [15:0] cmd_cycle_end ;  // a- 20140923(1)
    reg red_bg ;  // a-3 20140930(1)
    reg green_bg ;
    reg blue_bg ;

////////////////  internal wire and registers end  /////////////////////////////

////////////////  internal signals  ////////////////////////////////////////////
////////////////  for pcd_sta  ////////////////
  ////////  frame_upd_keep signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140923(1)
    begin
      if (!rst_n)
        frame_upd_keep <= 1'b0 ;
      else
        if (frame_upd_start)
          frame_upd_keep <= 1'b1 ;
        else
          if ((pcd_sta == PCD_FRAME_END) &&
              (sp_addr == 319)
             )
            frame_upd_keep <= 1'b0 ;
          else
            frame_upd_keep <= frame_upd_keep ;
    end
  ////////  frame_upd_keep signal end  ////////////////

  ////////  single_upd_keep signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140923(1)
    begin
      if (!rst_n)
        single_upd_keep <= 1'b0 ;
      else
        if (single_upd_start)
          single_upd_keep <= 1'b1 ;
        else
          if (pcd_sta == PCD_FRAME_END)
            single_upd_keep <= 1'b0 ;
          else
            single_upd_keep <= single_upd_keep ;
    end
  ////////  single_upd_keep signal end  ////////////////

  ////////  display_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140916(1)
    begin
      if (!rst_n)
        display_enb <= 1'b0 ;
      else
        if ((pcd_sta == PCD_IDLE) && (frame_cnt == 8'h08))  // m- 20140925(1)
          display_enb <= 1'b1 ;
        else
          display_enb <= display_enb ;
    end
  ////////  display_enb signal end  ////////////////

  ////////  initial_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140916(1)
    begin
      if (!rst_n)
        initial_enb <= 1'b0 ;
      else
        case(pcd_sta)  // synopsys parallel_case
          PCD_IDLE : initial_enb <= 1'b1 ;
          PCD_DISP_IDLE : initial_enb <= 1'b0 ;
          default : initial_enb <= initial_enb ;
        endcase  // pcd_sta
    end
  ////////  initial_enb signal end  ////////////////

  ////////  common_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140916(1)
    begin
      if (!rst_n)
        common_cnt <= 'b0 ;
      else
        if (pcd_sta == PCD_IDLE)
          common_cnt <= common_cnt + 1'b1 ;
        else
          common_cnt <= 'b0 ;
    end
  ////////  common_cnt bus end  ////////////////

  ////////  cmd_start signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd_start <= 1'b0 ;
      else
        case(pcd_sta)  // synopsys parallel_case
          PCD_IDLE :
            begin
              if (pcd_nxt == PCD_PIXSET)  // m- 20140924(1)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_PIXSET :    // a- 20140924(1)
            begin
              if (pcd_nxt == PCD_SLPOUT)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_SLPOUT :
            begin
              if (pcd_nxt == PCD_RDDSDR)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_CHK_RL_F : cmd_start <= 1'b1 ;
          PCD_RGBSET :
            begin
              if (pcd_nxt == PCD_DISPON)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_DISP_IDLE :
            begin
              if (pcd_nxt == PCD_CASET)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_CASET :
            begin
              if (pcd_nxt == PCD_PASET)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_PASET :
            begin
              if (pcd_nxt == PCD_RAMWR)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          PCD_FRAME_END :
            begin
              if (pcd_nxt == PCD_CASET)
                cmd_start <= 1'b1 ;
              else
                cmd_start <= 1'b0 ;
            end
          default : cmd_start <= 1'b0 ;
        endcase  // pcd_sta
    end
  ////////  cmd_start signal end  ////////////////

  ////////  cmd_reg bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd_reg <= 'b0 ;
      else
        case(pcd_sta)  // synopsys parallel_case
          PCD_IDLE :
            begin
              if (pcd_nxt == PCD_PIXSET)  // m-2 20140924(1)
                cmd_reg <= 8'h3A ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_PIXSET :    // a- 20140924(1)
            begin
              if (pcd_nxt == PCD_SLPOUT)
                cmd_reg <= 8'h11 ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_SLPOUT :
            begin
              if (pcd_nxt == PCD_RDDSDR)
                cmd_reg <= 8'h0F ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_CHK_RL_F :
            begin
              if (pcd_nxt == PCD_RDDSDR)
                cmd_reg <= 8'h0F ;
              else
                cmd_reg <= 8'h2D ;
            end
          PCD_RGBSET :
            begin
              if (pcd_nxt == PCD_DISPON)
                cmd_reg <= 8'h29 ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_DISP_IDLE :
            begin
              if (pcd_nxt == PCD_CASET)
                cmd_reg <= 8'h2A ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_CASET :
            begin
              if (pcd_nxt == PCD_PASET)
                cmd_reg <= 8'h2B ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_PASET :
            begin
              if (pcd_nxt == PCD_RAMWR)
                cmd_reg <= 8'h2C ;
              else
                cmd_reg <= cmd_reg ;
            end
          PCD_FRAME_END :
            begin
              if (pcd_nxt == PCD_CASET)
                cmd_reg <= 8'h2A ;
              else
                cmd_reg <= cmd_reg ;
            end
          default : cmd_reg <= cmd_reg ;
        endcase  // pcd_sta
    end
  ////////  cmd_reg bus end  ////////////////

  ////////  cmd_cycle_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_PIXSET : cmd_cycle_reg = 2 ;  // a- 20140924(1)
        CMD_SLPOUT : cmd_cycle_reg = 1 ;
        CMD_RDDSDR : cmd_cycle_reg = 2 ;
        CMD_DISPON : cmd_cycle_reg = 1 ;
        CMD_CASET  : cmd_cycle_reg = 5 ;
        CMD_PASET  : cmd_cycle_reg = 5 ;
        CMD_RAMWR  :    // m- 20140923(1)
          begin
            if (single_upd_start || single_upd_keep)
              cmd_cycle_reg = 2 ;
            else
              cmd_cycle_reg = 'b0 ;
          end
        CMD_RGBSET : cmd_cycle_reg = 129 ;
        default    : cmd_cycle_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  cmd_cycle_reg bus end  ////////////////

  ////////  par_enb_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_PIXSET : par_enb_reg = 8'b0000_0001 ;  // a- 20140924(1)
        CMD_CASET  : par_enb_reg = 8'b0000_1111 ;
        CMD_PASET  : par_enb_reg = 8'b0000_1111 ;
        default    : par_enb_reg = 8'b0000_0000 ;
      endcase  // cmd_reg
    end
  ////////  par_enb_reg bus end  ////////////////

  ////////  par1_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_PIXSET : par1_reg = {8'h00, 8'h55} ;  // a- 20140924(1)
        CMD_CASET  : par1_reg = {8'h00, sc_addr[15:8]} ;
        CMD_PASET  : par1_reg = {8'h00, sp_addr[15:8]} ;
        default    : par1_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par1_reg bus end  ////////////////

  ////////  par2_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par2_reg = {8'h00, sc_addr[7:0]} ;
        CMD_PASET  : par2_reg = {8'h00, sp_addr[7:0]} ;
        default    : par2_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par2_reg bus end  ////////////////

  ////////  par3_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par3_reg = {8'h00, ec_addr[15:8]} ;
        CMD_PASET  : par3_reg = {8'h00, ep_addr[15:8]} ;
        default    : par3_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par3_reg bus end  ////////////////

  ////////  par4_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par4_reg = {8'h00, ec_addr[7:0]} ;
        CMD_PASET  : par4_reg = {8'h00, ep_addr[7:0]} ;
        default    : par4_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par4_reg bus end  ////////////////

  ////////  par5_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par5_reg = 'b0 ;
        CMD_PASET  : par5_reg = 'b0 ;
        default    : par5_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par5_reg bus end  ////////////////

  ////////  par6_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par6_reg = 'b0 ;
        CMD_PASET  : par6_reg = 'b0 ;
        default    : par6_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par6_reg bus end  ////////////////

  ////////  par7_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par7_reg = 'b0 ;
        CMD_PASET  : par7_reg = 'b0 ;
        default    : par7_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par7_reg bus end  ////////////////

  ////////  par8_reg bus  ////////////////
  always @(*)
    begin
      case(cmd_reg)  // synopsys parallel_case
        CMD_CASET  : par8_reg = 'b0 ;
        CMD_PASET  : par8_reg = 'b0 ;
        default    : par8_reg = 'b0 ;
      endcase  // cmd_reg
    end
  ////////  par8_reg bus end  ////////////////

  ////////  frame_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        frame_cnt <= 'b0 ;
      else    // m- 20140925(1)
        case(pcd_sta)  // synopsys parallel_case
          PCD_IDLE,
          PCD_WAIT_DELAY,
          PCD_RDDSDR,
          PCD_CHK_RL_F :
            begin
              if (trigger_33ms)
                frame_cnt <= frame_cnt + 1'b1 ;
              else
                frame_cnt <= frame_cnt ;
            end
          default : frame_cnt <= 'b0 ;
        endcase  // pcd_sta
    end
  ////////  frame_cnt bus end  ////////////////

  ////////  disp_start signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        disp_start <= 1'b0 ;
      else
        disp_start <= trigger_33ms ;
    end
  ////////  disp_start signal end  ////////////////

  ////////  sc_addr bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        sc_addr <= 'b0 ;
      else
        if (single_upd_start || single_upd_keep)  // a-3 20140923(1)
          sc_addr <= {7'b0, x_coordinate} ;
        else
          sc_addr <= 'b0 ;
    end
  ////////  sc_addr bus end  ////////////////

  ////////  ec_addr bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        ec_addr <= 'b0 ;
      else
        if (single_upd_start || single_upd_keep)  // a-3 20140923(1)
          ec_addr <= {7'b0, x_coordinate} ;  // m- 20140926(1)
        else
          ec_addr <= 16'h00EF ;
    end
  ////////  ec_addr bus end  ////////////////

  ////////  sp_addr bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        sp_addr <= 'b0 ;
      else
        if (frame_upd_start || frame_upd_keep)  // 1- 20140923(1)
          if (pcd_sta == PCD_FRAME_END)
            sp_addr <= sp_addr + 1'b1 ;
          else
            if (pcd_sta == PCD_DISP_IDLE)
              sp_addr <= 'b0 ;
            else
              sp_addr <= sp_addr ;
        else    // a- 20140923(1)
          if (single_upd_start)
            sp_addr <= {7'h00, y_coordinate} ;
          else
            sp_addr <= sp_addr ;
    end
  ////////  sp_addr bus end  ////////////////

  ////////  ep_addr bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        ep_addr <= 'b0 ;
      else
        ep_addr <= sp_addr ;
    end
  ////////  ep_addr bus end  ////////////////

  ////////  rgbset_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        rgbset_finish <= 1'b0 ;
      else
        case(pcd_sta)  // synopsys parallel_case
          PCD_IDLE : rgbset_finish <= 1'b0 ;
          PCD_RGBSET :
            begin
              if (dpy_cmd_finish)
                rgbset_finish <= 1'b1 ;
              else
                rgbset_finish <= rgbset_finish ;
            end
          default : rgbset_finish <= rgbset_finish ;
        endcase  // pcd_sta
    end
  ////////  rgbset_finish signal end  ////////////////

  ////////  dispon_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        dispon_finish <= 1'b0 ;
      else
        case(pcd_sta)  // synopsys parallel_case
          PCD_IDLE : dispon_finish <= 1'b0 ;
          PCD_WAIT_DELAY :
            begin
              if (frame_cnt == 3)
                dispon_finish <= 1'b1 ;
              else
                dispon_finish <= dispon_finish ;
            end
          default : dispon_finish <= dispon_finish ;
        endcase  // pcd_sta
    end
  ////////  dispon_finish signal end  ////////////////

////////////////  for pcd_sta end  ////////////////

////////////////  for dpy_sta  ////////////////
  ////////  red_bg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140930(1)
    begin
      if (!rst_n)
        red_bg <= 1'b0 ;
      else
        if (dpy_sta == DPY_READ_BUFF)
          if (((sp_addr <= 319) && (sp_addr >= 299)) &&
              ((cmd_cnt <=  80) && (cmd_cnt >=  60))
             )
            red_bg <= 1'b1 ;
          else
            red_bg <= 1'b0 ;
        else
          red_bg <= 1'b0 ;
    end
  ////////  red_bg signal end  ////////////////

  ////////  green_bg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140930(1)
    begin
      if (!rst_n)
        green_bg <= 1'b0 ;
      else
        if (dpy_sta == DPY_READ_BUFF)
          if (((sp_addr <= 319) && (sp_addr >= 299)) &&
              ((cmd_cnt <= 130) && (cmd_cnt >= 110))
             )
            green_bg <= 1'b1 ;
          else
            green_bg <= 1'b0 ;
        else
          green_bg <= 1'b0 ;
    end
  ////////  green_bg signal end  ////////////////

  ////////  blue_bg signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140930(1)
    begin
      if (!rst_n)
        blue_bg <= 1'b0 ;
      else
        if (dpy_sta == DPY_READ_BUFF)
          if (((sp_addr <= 319) && (sp_addr >= 299)) &&
              ((cmd_cnt <= 180) && (cmd_cnt >= 160))
             )
            blue_bg <= 1'b1 ;
          else
            blue_bg <= 1'b0 ;
        else
          blue_bg <= 1'b0 ;
    end
  ////////  blue_bg signal end  ////////////////

  ////////  cmd_cycle_end bus  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140923(1)
    begin
      if (!rst_n)
        cmd_cycle_end <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_CMD_START : cmd_cycle_end <= cmd_cycle_reg ;
          DPY_NOP : cmd_cycle_end <= 1 ;
          default : cmd_cycle_end <= cmd_cycle_end ;
        endcase  // dpy_sta
    end
  ////////  cmd_cycle_end bus end  ////////////////

  ////////  dpy_cmd_finish signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        dpy_cmd_finish <= 1'b0 ;
      else
        if (dpy_sta == DPY_FINISH)
          dpy_cmd_finish <= 1'b1 ;
        else
          dpy_cmd_finish <= 1'b0 ;
    end
  ////////  dpy_cmd_finish signal end  ////////////////

  ////////  par_enb bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par_enb <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par_enb <= par_enb_reg ;
              else
                par_enb <= par_enb ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par_enb <= {1'b0, par_enb[7:1]}  ;
              else
                par_enb <= par_enb ;
            end
          default : par_enb <= par_enb ;
        endcase  // dpy_sta
    end
  ////////  par_enb bus end  ////////////////

  ////////  par1 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par1 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par1 <= par1_reg ;
              else
                par1 <= par1 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par1 <= par2 ;
              else
                par1 <= par1 ;
            end
          default : par1 <= par1 ;
        endcase  // dpy_sta
    end
  ////////  par1 bus end  ////////////////

  ////////  par2 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par2 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par2 <= par2_reg ;
              else
                par2 <= par2 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par2 <= par3 ;
              else
                par2 <= par2 ;
            end
          default : par2 <= par2 ;
        endcase  // dpy_sta
    end
  ////////  par2 bus end  ////////////////

  ////////  par3 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par3 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par3 <= par3_reg ;
              else
                par3 <= par3 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par3 <= par4 ;
              else
                par3 <= par3 ;
            end
          default : par3 <= par3 ;
        endcase  // dpy_sta
    end
  ////////  par3 bus end  ////////////////

  ////////  par4 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par4 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par4 <= par4_reg ;
              else
                par4 <= par4 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par4 <= par5 ;
              else
                par4 <= par4 ;
            end
          default : par4 <= par4 ;
        endcase  // dpy_sta
    end
  ////////  par4 bus end  ////////////////

  ////////  par5 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par5 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par5 <= par5_reg ;
              else
                par5 <= par5 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par5 <= par6 ;
              else
                par5 <= par5 ;
            end
          default : par5 <= par5 ;
        endcase  // dpy_sta
    end
  ////////  par5 bus end  ////////////////

  ////////  par6 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par6 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par6 <= par6_reg ;
              else
                par6 <= par6 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par6 <= par7 ;
              else
                par6 <= par6 ;
            end
          default : par6 <= par6 ;
        endcase  // dpy_sta
    end
  ////////  par6 bus end  ////////////////

  ////////  par7 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par7 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par7 <= par7_reg ;
              else
                par7 <= par7 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par7 <= par8 ;
              else
                par7 <= par7 ;
            end
          default : par7 <= par7 ;
        endcase  // dpy_sta
    end
  ////////  par7 bus end  ////////////////

  ////////  par8 bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        par8 <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE :
            begin
              if (cmd_start)
                par8 <= par8_reg ;
              else
                par8 <= par8 ;
            end
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                par8 <= 'b0  ;
              else
                par8 <= par8 ;
            end
          default : par8 <= par8 ;
        endcase  // dpy_sta
    end
  ////////  par8 bus end  ////////////////

  ////////  cmd_cnt bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd_cnt <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE : cmd_cnt <= 'b0 ;
          DPY_CMD_START : cmd_cnt <= cmd_cnt + 1'b1 ;
          DPY_PAR_OUT :
            begin
              if (!data_wr_valid && par_enb[0])
                cmd_cnt <= cmd_cnt + 1'b1 ;
              else
                cmd_cnt <= cmd_cnt ;
            end
          DPY_READ_BUFF :
            begin
              if (data_bvld_ack)
                cmd_cnt <= cmd_cnt + 1'b1 ;
              else
                cmd_cnt <= cmd_cnt ;
            end
          DPY_READ_LUT :
            begin
              if (!lut_data_valid)
                cmd_cnt <= cmd_cnt + 1'b1 ;
              else
                cmd_cnt <= cmd_cnt ;
            end
          DPY_PAR_IN :
            begin
              if (data_rd_valid)
                cmd_cnt <= cmd_cnt + 1'b1 ;
              else
                cmd_cnt <= cmd_cnt ;
            end
          default : cmd_cnt <= cmd_cnt ;
        endcase  // dpy_sta
    end
  ////////  cmd_cnt bus end  ////////////////

  ////////  lut_read_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        lut_read_enb <= 1'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_CMD_START :
            begin
              if (cmd_reg == CMD_RGBSET)
                lut_read_enb <= 1'b1 ;
              else
                lut_read_enb <= 1'b0 ;
            end
          DPY_READ_LUT :
            begin
              if (!lut_data_valid)
                lut_read_enb <= 1'b1 ;
              else
                lut_read_enb <= 1'b0 ;
            end
          default : lut_read_enb <= 1'b0 ;
        endcase  // dpy_sta
    end
  ////////  lut_read_enb signal end  ////////////////

  ////////  lut_addr_rd bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        lut_addr_rd <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_IDLE : lut_addr_rd <= 'b0 ;
          DPY_CMD_START : lut_addr_rd <= 'b0 ;
          default :
            begin
              if (lut_read_enb)
                lut_addr_rd <= lut_addr_rd + 1'b1 ;
              else
                lut_addr_rd <= lut_addr_rd ;
            end
        endcase  // dpy_sta
    end
  ////////  lut_addr_rd bus end  ////////////////

  ////////  lut_data_valid signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        lut_data_valid <= 1'b0 ;
      else
        if (lut_read_enb)
          lut_data_valid <= 1'b1 ;
        else
          if (!data_wr_valid && lut_data_valid)
            lut_data_valid <= 1'b0 ;
          else
            lut_data_valid <= lut_data_valid ;
    end
  ////////  lut_data_valid signal end  ////////////////

  ////////  lut_data_buf bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        lut_data_buf <= 'b0 ;
      else
        if (lut_read_enb)    // m- 20140917(1)
          case(lut_addr_rd)  // synopsys parallel_case
            0   : lut_data_buf <= 8'b0000_0000 ;  // R0 
            1   : lut_data_buf <= 8'b0000_0010 ;  // R1 
            2   : lut_data_buf <= 8'b0000_0100 ;  // R2 
            3   : lut_data_buf <= 8'b0000_0110 ;  // R3 
            4   : lut_data_buf <= 8'b0000_1000 ;  // R4 
            5   : lut_data_buf <= 8'b0000_1010 ;  // R5 
            6   : lut_data_buf <= 8'b0000_1100 ;  // R6 
            7   : lut_data_buf <= 8'b0000_1110 ;  // R7 
            8   : lut_data_buf <= 8'b0001_0000 ;  // R8 
            9   : lut_data_buf <= 8'b0001_0010 ;  // R9 
            10  : lut_data_buf <= 8'b0001_0100 ;  // R10
            11  : lut_data_buf <= 8'b0001_0110 ;  // R11
            12  : lut_data_buf <= 8'b0001_1000 ;  // R12
            13  : lut_data_buf <= 8'b0001_1010 ;  // R13
            14  : lut_data_buf <= 8'b0001_1100 ;  // R14
            15  : lut_data_buf <= 8'b0001_1110 ;  // R15
            16  : lut_data_buf <= 8'b0010_0001 ;  // R16
            17  : lut_data_buf <= 8'b0010_0011 ;  // R17
            18  : lut_data_buf <= 8'b0010_0101 ;  // R18
            19  : lut_data_buf <= 8'b0010_0111 ;  // R19
            20  : lut_data_buf <= 8'b0010_1001 ;  // R20
            21  : lut_data_buf <= 8'b0010_1011 ;  // R21
            22  : lut_data_buf <= 8'b0010_1101 ;  // R22
            23  : lut_data_buf <= 8'b0010_1111 ;  // R23
            24  : lut_data_buf <= 8'b0011_0001 ;  // R24
            25  : lut_data_buf <= 8'b0011_0011 ;  // R25
            26  : lut_data_buf <= 8'b0011_0101 ;  // R26
            27  : lut_data_buf <= 8'b0011_0111 ;  // R27
            28  : lut_data_buf <= 8'b0011_1001 ;  // R28
            29  : lut_data_buf <= 8'b0011_1011 ;  // R29
            30  : lut_data_buf <= 8'b0011_1101 ;  // R30
            31  : lut_data_buf <= 8'b0011_1111 ;  // R31
            32  : lut_data_buf <= 8'b0000_0000 ;  // G0 
            33  : lut_data_buf <= 8'b0000_0001 ;  // G1 
            34  : lut_data_buf <= 8'b0000_0010 ;  // G2 
            35  : lut_data_buf <= 8'b0000_0011 ;  // G3 
            36  : lut_data_buf <= 8'b0000_0100 ;  // G4 
            37  : lut_data_buf <= 8'b0000_0101 ;  // G5 
            38  : lut_data_buf <= 8'b0000_0110 ;  // G6 
            39  : lut_data_buf <= 8'b0000_0111 ;  // G7 
            40  : lut_data_buf <= 8'b0000_1000 ;  // G8 
            41  : lut_data_buf <= 8'b0000_1001 ;  // G9 
            42  : lut_data_buf <= 8'b0000_1010 ;  // G10
            43  : lut_data_buf <= 8'b0000_1011 ;  // G11
            44  : lut_data_buf <= 8'b0000_1100 ;  // G12
            45  : lut_data_buf <= 8'b0000_1101 ;  // G13
            46  : lut_data_buf <= 8'b0000_1110 ;  // G14
            47  : lut_data_buf <= 8'b0000_1111 ;  // G15
            48  : lut_data_buf <= 8'b0001_0000 ;  // G16
            49  : lut_data_buf <= 8'b0001_0001 ;  // G17
            50  : lut_data_buf <= 8'b0001_0010 ;  // G18
            51  : lut_data_buf <= 8'b0001_0011 ;  // G19
            52  : lut_data_buf <= 8'b0001_0100 ;  // G20
            53  : lut_data_buf <= 8'b0001_0101 ;  // G21
            54  : lut_data_buf <= 8'b0001_0110 ;  // G22
            55  : lut_data_buf <= 8'b0001_0111 ;  // G23
            56  : lut_data_buf <= 8'b0001_1000 ;  // G24
            57  : lut_data_buf <= 8'b0001_1001 ;  // G25
            58  : lut_data_buf <= 8'b0001_1010 ;  // G26
            59  : lut_data_buf <= 8'b0001_1011 ;  // G27
            60  : lut_data_buf <= 8'b0001_1100 ;  // G28
            61  : lut_data_buf <= 8'b0001_1101 ;  // G29
            62  : lut_data_buf <= 8'b0001_1110 ;  // G30
            63  : lut_data_buf <= 8'b0001_1111 ;  // G31
            64  : lut_data_buf <= 8'b0010_0000 ;  // G32 
            65  : lut_data_buf <= 8'b0010_0001 ;  // G33
            66  : lut_data_buf <= 8'b0010_0010 ;  // G34
            67  : lut_data_buf <= 8'b0010_0011 ;  // G35
            68  : lut_data_buf <= 8'b0010_0100 ;  // G36
            69  : lut_data_buf <= 8'b0010_0101 ;  // G37
            70  : lut_data_buf <= 8'b0010_0110 ;  // G38
            71  : lut_data_buf <= 8'b0010_0111 ;  // G39
            72  : lut_data_buf <= 8'b0010_1000 ;  // G40
            73  : lut_data_buf <= 8'b0010_1001 ;  // G41
            74  : lut_data_buf <= 8'b0010_1010 ;  // G42
            75  : lut_data_buf <= 8'b0010_1011 ;  // G43
            76  : lut_data_buf <= 8'b0010_1100 ;  // G44
            77  : lut_data_buf <= 8'b0010_1101 ;  // G45
            78  : lut_data_buf <= 8'b0010_1110 ;  // G46
            79  : lut_data_buf <= 8'b0010_1111 ;  // G47
            80  : lut_data_buf <= 8'b0011_0000 ;  // G48
            81  : lut_data_buf <= 8'b0011_0001 ;  // G49
            82  : lut_data_buf <= 8'b0011_0010 ;  // G50
            83  : lut_data_buf <= 8'b0011_0011 ;  // G51
            84  : lut_data_buf <= 8'b0011_0100 ;  // G52
            85  : lut_data_buf <= 8'b0011_0101 ;  // G53
            86  : lut_data_buf <= 8'b0011_0110 ;  // G54
            87  : lut_data_buf <= 8'b0011_0111 ;  // G55
            88  : lut_data_buf <= 8'b0011_1000 ;  // G56
            89  : lut_data_buf <= 8'b0011_1001 ;  // G57
            90  : lut_data_buf <= 8'b0011_1010 ;  // G58
            91  : lut_data_buf <= 8'b0011_1011 ;  // G59
            92  : lut_data_buf <= 8'b0011_1100 ;  // G60
            93  : lut_data_buf <= 8'b0011_1101 ;  // G61
            94  : lut_data_buf <= 8'b0011_1110 ;  // G62
            95  : lut_data_buf <= 8'b0011_1111 ;  // G63
            96  : lut_data_buf <= 8'b0000_0000 ;  // B0 
            97  : lut_data_buf <= 8'b0000_0010 ;  // B1 
            98  : lut_data_buf <= 8'b0000_0100 ;  // B2 
            99  : lut_data_buf <= 8'b0000_0110 ;  // B3 
            100 : lut_data_buf <= 8'b0000_1000 ;  // B4 
            101 : lut_data_buf <= 8'b0000_1010 ;  // B5 
            102 : lut_data_buf <= 8'b0000_1100 ;  // B6 
            103 : lut_data_buf <= 8'b0000_1110 ;  // B7 
            104 : lut_data_buf <= 8'b0001_0000 ;  // B8 
            105 : lut_data_buf <= 8'b0001_0010 ;  // B9 
            106 : lut_data_buf <= 8'b0001_0100 ;  // B10
            107 : lut_data_buf <= 8'b0001_0110 ;  // B11
            108 : lut_data_buf <= 8'b0001_1000 ;  // B12
            109 : lut_data_buf <= 8'b0001_1010 ;  // B13
            110 : lut_data_buf <= 8'b0001_1100 ;  // B14
            111 : lut_data_buf <= 8'b0001_1110 ;  // B15
            112 : lut_data_buf <= 8'b0010_0001 ;  // B16
            113 : lut_data_buf <= 8'b0010_0011 ;  // B17
            114 : lut_data_buf <= 8'b0010_0101 ;  // B18
            115 : lut_data_buf <= 8'b0010_0111 ;  // B19
            116 : lut_data_buf <= 8'b0010_1001 ;  // B20
            117 : lut_data_buf <= 8'b0010_1011 ;  // B21
            118 : lut_data_buf <= 8'b0010_1101 ;  // B22
            119 : lut_data_buf <= 8'b0010_1111 ;  // B23
            120 : lut_data_buf <= 8'b0011_0001 ;  // B24
            121 : lut_data_buf <= 8'b0011_0011 ;  // B25
            122 : lut_data_buf <= 8'b0011_0101 ;  // B26
            123 : lut_data_buf <= 8'b0011_0111 ;  // B27
            124 : lut_data_buf <= 8'b0011_1001 ;  // B28
            125 : lut_data_buf <= 8'b0011_1011 ;  // B29
            126 : lut_data_buf <= 8'b0011_1101 ;  // B30
            127 : lut_data_buf <= 8'b0011_1111 ;  // B31
          endcase  // lut_addr_rd
        else
          lut_data_buf <= lut_data_buf ;
    end
  ////////  lut_data_buf bus end  ////////////////

  ////////  rl_detect signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        rl_detect <= 1'b0 ;
      else
        if (data_rd_valid && ack_rd)
          if (dsdr_latch)
            rl_detect <= data_rd[7] ;
          else
            rl_detect <= rl_detect ;
        else
          rl_detect <= rl_detect ;
    end
  ////////  rl_detect signal end  ////////////////

  ////////  func_detect signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        func_detect <= 1'b0 ;
      else
        if (data_rd_valid && ack_rd)
          if (dsdr_latch)
            func_detect <= data_rd[6] ;
          else
            func_detect <= func_detect ;
        else
          func_detect <= func_detect ;
    end
  ////////  func_detect signal end  ////////////////

  ////////  dsdr_latch signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        dsdr_latch <= 1'b0 ;
      else
        if (dpy_sta == DPY_CMD_START)
          if (cmd_reg == CMD_RDDSDR)
            dsdr_latch <= 1'b1 ;
          else
            dsdr_latch <= dsdr_latch ;
        else
          if (dpy_sta == DPY_FINISH)
            dsdr_latch <= 1'b0 ;
          else
            dsdr_latch <= dsdr_latch ;
    end
  ////////  dsdr_latch signal end  ////////////////
////////////////  for dpy_sta end  ////////////////
////////////////  internal signals end  ////////////////////////////////////////

////////////////  dpy_sta FSM  /////////////////////////////////////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        dpy_sta <= DPY_IDLE ;
      else
        dpy_sta <= dpy_nxt ;
    end

  always @(*)
    begin
      case(dpy_sta)  // synopsys parallel_case
        DPY_IDLE :
          begin
            if (cmd_start)
              dpy_nxt = DPY_CMD_START ;
            else
              dpy_nxt = DPY_IDLE ;
          end
        DPY_CMD_START :
          begin
            case(cmd_reg)  // synopsys parallel_case
              CMD_PIXSET : dpy_nxt = DPY_WRITE_REG ;  // a- 20140924(1)
              CMD_SLPOUT : dpy_nxt = DPY_WRITE_REG ;
              CMD_RDDSDR : dpy_nxt = DPY_READ_REG ;
              CMD_DISPON : dpy_nxt = DPY_WRITE_REG ;
              CMD_CASET : dpy_nxt = DPY_WRITE_REG ;
              CMD_PASET : dpy_nxt = DPY_WRITE_REG ;
              CMD_RAMWR : dpy_nxt = DPY_WRITE_PAT ;
              CMD_RGBSET : dpy_nxt = DPY_WRITE_LUT ;
              default : dpy_nxt = DPY_IDLE ;
            endcase  // cmd_reg
          end
        DPY_WRITE_REG :
          begin
            if (cmd_cycle_end == 1)  // m- 20140923(1)
              dpy_nxt = DPY_CHK_OUTNUMB ;
            else
              dpy_nxt = DPY_PAR_OUT ;
          end
        DPY_PAR_OUT :
          begin
            if (!data_wr_valid && par_enb[0])
              dpy_nxt = DPY_CHK_OUTNUMB ;
            else
              dpy_nxt = DPY_PAR_OUT ;
          end
        DPY_CHK_OUTNUMB :
          begin
            if (cmd_cnt == cmd_cycle_end)  // m- 20140923(1)
              dpy_nxt = DPY_WAIT_FINISH ;
            else
              dpy_nxt = DPY_PAR_OUT ;
          end
        DPY_WRITE_PAT : dpy_nxt = DPY_READ_BUFF ;
        DPY_READ_BUFF :
          begin
            if (data_bvld_ack)
              dpy_nxt = DPY_CHK_BUFNUMB ;
            else
              dpy_nxt = DPY_READ_BUFF ;
          end
        DPY_CHK_BUFNUMB :
          begin
            if ((cmd_cnt == cmd_cycle_end) ||
                (cmd_cnt == 241)  // 240 data + 1 command
               )  // m- 20140923(1)
              if (wrphase_finish)  // m- 20140923(1)
                dpy_nxt = DPY_NOP ;
              else
                dpy_nxt = DPY_CHK_BUFNUMB ;
            else
              dpy_nxt = DPY_READ_BUFF ;
          end
        DPY_NOP : dpy_nxt = DPY_WAIT_FINISH ;
        DPY_WRITE_LUT : dpy_nxt = DPY_READ_LUT ;
        DPY_READ_LUT :
          begin
            if (!lut_data_valid)
              dpy_nxt = DPY_CHK_LUTNUMB ;
            else
              dpy_nxt = DPY_READ_LUT ;
          end
        DPY_CHK_LUTNUMB :
          begin
            if (cmd_cnt == 129)  // 128 data + 1 command
              dpy_nxt = DPY_WAIT_FINISH ;
            else
              dpy_nxt = DPY_READ_LUT ;
          end
        DPY_READ_REG : dpy_nxt = DPY_PAR_IN ;
        DPY_PAR_IN :
          begin
            if (data_rd_valid)
              dpy_nxt = DPY_CHK_INNUMB ;
            else
              dpy_nxt = DPY_PAR_IN ;
          end
        DPY_CHK_INNUMB :
          begin
            if (cmd_cnt == cmd_cycle_end)  // m- 20140923(1)
              dpy_nxt = DPY_WAIT_FINISH ;
            else
              dpy_nxt = DPY_PAR_IN ;
          end
        DPY_WAIT_FINISH :
          begin
            if (cmd_finish)
              dpy_nxt = DPY_FINISH ;
            else
              dpy_nxt = DPY_WAIT_FINISH ;
          end
        DPY_FINISH : dpy_nxt = DPY_IDLE ;
        default : dpy_nxt = DPY_IDLE ;
      endcase  // dpy_sta
    end
////////////////  dpy_sta FSM  /////////////////////////////////////////////////

////////////////  pcd_sta FSM  /////////////////////////////////////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        pcd_sta <= PCD_IDLE ;
      else
        pcd_sta <= pcd_nxt ;
    end

  always @(*)
    begin
      case(pcd_sta)  // synopsys parallel_case
        PCD_IDLE :    // m- 20140916(1)
          begin
            if (display_enb)
              if (initial_enb)
                pcd_nxt = PCD_PIXSET ;  // m- 20140924(1)
              else
                pcd_nxt = PCD_DISP_IDLE ;
            else
              pcd_nxt = PCD_IDLE ;
          end
        PCD_PIXSET :    // a- 20140924(1)
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_SLPOUT ;
            else
              pcd_nxt = PCD_PIXSET ;
          end
        PCD_SLPOUT :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_RDDSDR ;
            else
              pcd_nxt = PCD_SLPOUT ;
          end
        PCD_RDDSDR :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_CHK_RL_F ;
            else
              pcd_nxt = PCD_RDDSDR ;
          end
        PCD_CHK_RL_F :
          begin
            if (rl_detect && func_detect)
              pcd_nxt = PCD_RGBSET ;
            else
              pcd_nxt = PCD_RDDSDR ;
          end
        PCD_RGBSET :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_DISPON ;
            else
              pcd_nxt = PCD_RGBSET ;
          end
        PCD_DISPON :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_WAIT_DELAY ;
            else
              pcd_nxt = PCD_DISPON ;
          end
        PCD_WAIT_DELAY :
          begin
            if (frame_cnt == 3)
              pcd_nxt = PCD_DISP_IDLE ;
            else
              pcd_nxt = PCD_WAIT_DELAY ;
          end
        PCD_DISP_IDLE :
          begin
            if (frame_upd_start || single_upd_start)  // m- 20140923(1)
              pcd_nxt = PCD_CASET ;
            else
              pcd_nxt = PCD_DISP_IDLE ;
          end
        PCD_CASET :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_PASET ;
            else
              pcd_nxt = PCD_CASET ;
          end
        PCD_PASET :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_RAMWR ;
            else
              pcd_nxt = PCD_PASET ;
          end
        PCD_RAMWR :
          begin
            if (dpy_cmd_finish)
              pcd_nxt = PCD_FRAME_END ;
            else
              pcd_nxt = PCD_RAMWR ;
          end
        PCD_FRAME_END :
          begin
            if ((frame_upd_keep && (sp_addr == 319)) ||
                single_upd_keep
               )  // m- 20140923(1)
              pcd_nxt = PCD_DISP_IDLE ;
            else
              pcd_nxt = PCD_CASET ;
          end
        default : pcd_nxt = PCD_IDLE ;
      endcase  // pcd_sta
    end
////////////////  pcd_sta FSM  /////////////////////////////////////////////////

////////////////  BUFF_CTRL output  ////////////////////////////////////////////
  ////////  read_enb signal  ////////////////
  ////////  read_enb signal end  ////////////////

  ////////  sleep_off signal  ////////////////
  always @(posedge clk or negedge rst_n)    // a- 20140925(2)
    begin
      if (!rst_n)
        sleep_off <= 1'b0 ;
      else
        if (rl_detect && func_detect)
          sleep_off <= 1'b1 ;
        else
          sleep_off <= 1'b0 ;
    end
  ////////  sleep_off signal end  ////////////////

  ////////  data_bvld_ack signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_bvld_ack <= 1'b0 ;
      else
        if ((dpy_sta == DPY_READ_BUFF) &&
            (!data_wr_valid && data_buf_valid)
           )  // m- 20140923(1)
          data_bvld_ack <= 1'b1 ;
        else
          data_bvld_ack <= 1'b0 ;
    end
  ////////  data_bvld_ack signal end  ////////////////
////////////////  BUFF_CTRL output end /////////////////////////////////////////

////////////////  CMD2LCD output  //////////////////////////////////////////////
  ////////  cmd_valid signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd_valid <= 1'b0 ;
      else
        if ((dpy_sta == DPY_CMD_START) ||
            (dpy_sta == DPY_NOP)
           )
          cmd_valid <= 1'b1 ;
        else
          cmd_valid <= 1'b0 ;
    end
  ////////  cmd_valid signal end  ////////////////

  ////////  cmd bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd <= 'b0 ;
      else
        if (dpy_sta == DPY_CMD_START)
          cmd <= cmd_reg ;
        else
          if (dpy_sta == DPY_NOP)
            cmd <= 8'h00 ;
          else
            cmd <= cmd ;
    end
  ////////  cmd bus end  ////////////////

  ////////  read_cmd_enb signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        read_cmd_enb <= 1'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_CMD_START :
           begin
             case(cmd_reg)  // synopsys parallel_case
               CMD_RDDSDR : read_cmd_enb <= 1'b1 ;
               default    : read_cmd_enb <= read_cmd_enb ;
             endcase  // cmd_reg
           end
          DPY_NOP : read_cmd_enb <= 1'b0 ;
          DPY_FINISH : read_cmd_enb <= 1'b0 ;
          default : read_cmd_enb <= read_cmd_enb ;
        endcase  // dpy_sta
    end
  ////////  read_cmd_enb signal end  ////////////////

  ////////  cmd_cycle bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        cmd_cycle <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_CMD_START :
            begin
              if (cmd_reg == CMD_RAMWR)
                cmd_cycle <= 'b0 ;
              else
                cmd_cycle <= cmd_cycle_reg ;
            end
          DPY_NOP : cmd_cycle <= 1 ;
          default : cmd_cycle <= cmd_cycle ;
        endcase  // dpy_sta
    end
  ////////  cmd_cycle bus end  ////////////////

  ////////  data_wr_valid signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_wr_valid <= 1'b0 ;
      else
        if (ack_wr)
          data_wr_valid <= 1'b0 ;
        else
          case(dpy_sta)  // synopsys parallel_case
            DPY_PAR_OUT :
             begin
               if (!data_wr_valid && par_enb[0])
                 data_wr_valid <= 1'b1 ;
               else
                 data_wr_valid <= data_wr_valid ;
             end
            DPY_READ_BUFF :
             begin
               if (!data_wr_valid && data_buf_valid)
                 data_wr_valid <= 1'b1 ;
               else
                 data_wr_valid <= data_wr_valid ;
             end
            DPY_READ_LUT :
             begin
               if (!data_wr_valid && lut_data_valid)
                 data_wr_valid <= 1'b1 ;
               else
                 data_wr_valid <= data_wr_valid ;
             end
            default : data_wr_valid <= data_wr_valid ;
          endcase  // dpy_sta
    end
  ////////  data_wr_valid signal end  ////////////////

  ////////  data_wr bus  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        data_wr <= 'b0 ;
      else
        case(dpy_sta)  // synopsys parallel_case
          DPY_PAR_OUT :
           begin
             if (!data_wr_valid && par_enb[0])
               data_wr <= par1 ;
             else
               data_wr <= data_wr ;
           end
            DPY_READ_BUFF :
             begin
               if (!data_wr_valid && data_buf_valid)    // m- 20140930(1)
                 case ({red_bg, green_bg, blue_bg})  // synopsys parallel_case
                   3'b001  : data_wr <= 16'hF800 ;
                   3'b010  : data_wr <= 16'h07E0 ;
                   3'b100  : data_wr <= 16'h001F ;
                   default : data_wr <= data_buff ;
                 endcase
               else
                 data_wr <= data_wr ;
             end
            DPY_READ_LUT :
             begin
               if (!data_wr_valid && lut_data_valid)
                 data_wr <= {8'h00, lut_data_buf} ;
               else
                 data_wr <= data_wr ;
             end
          default : data_wr <= data_wr ;
        endcase  // dpy_sta
    end
  ////////  data_wr bus end  ////////////////

  ////////  ack_rd signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        ack_rd <= 1'b0 ;
      else
        if ((dpy_sta == DPY_PAR_IN) && (data_rd_valid))
          ack_rd <= 1'b1 ;
        else
          ack_rd <= 1'b0 ;
    end
  ////////  ack_rd signal end  ////////////////
////////////////  CMD2LCD output end ///////////////////////////////////////////

////////////////  SYSTEM output  ///////////////////////////////////////////////
  ////////  frame_update signal  ////////////////
  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        frame_update <= 1'b0 ;
      else
        if ((pcd_sta == PCD_FRAME_END) &&
            ((frame_upd_keep && (sp_addr == 319)) ||
             single_upd_keep
            )
           )  // m- 20140923(1)
          frame_update <= 1'b1 ;
        else
          frame_update <= 1'b0 ;
    end
  ////////  frame_update signal end  ////////////////
////////////////  SYSTEM output end ////////////////////////////////////////////

endmodule  // display

