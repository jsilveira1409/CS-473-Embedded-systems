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

#include "terasic_includes.h"
#include "ILI9341.h"
#include "gui.h"
#include "touch_spi.h"
#include "system.h"

void GUI_VPG(alt_video_display *pDisplay, TOUCH_HANDLE *pTouch);

int main()
{
	TOUCH_HANDLE *pTouch;
	alt_video_display Display;


    const bool bVPG = ((IORD(KEY_BASE, 0x00) & 0x01) == 0x00)?TRUE:FALSE;

   printf("LT24 Demo!\n");

   // init touch
   pTouch = Touch_Init(TOUCH_PANEL_SPI_BASE, TOUCH_PANEL_PEN_IRQ_N_BASE, TOUCH_PANEL_PEN_IRQ_N_IRQ);
   if (!pTouch){
       printf("Failed to init touch\r\n");
   }else{
       printf("Init touch successfully\r\n");

   }

   // init LCD
   LCD_Init();
   LCD_Clear(0X0000);

   Display.interlace = 0;
   Display.bytes_per_pixel = 2;
   Display.color_depth = 16;
   Display.height = SCREEN_HEIGHT;
   Display.width = SCREEN_WIDTH;

   // run demo
   if (bVPG)
       GUI_VPG(&Display, pTouch); // enter vpg mode when users press KEY0
   else
	   GUI(&Display, pTouch);


}
