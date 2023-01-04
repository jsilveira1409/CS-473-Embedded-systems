/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

#include "stdio.h"
#include <inttypes.h>
#include "system.h"
#include "io.h"
#include "stdarg.h"

// Register map offsets
#define LCD_REG_IMG_ADDRESS_HIGH		0x00
#define LCD_REG_IMG_ADDRESS_LOW			0x01
#define LCD_REG_IMG_LENGTH_HIGH			0x02 
#define LCD_REG_IMG_LENGTH_LOW 			0x03
#define LCD_REG_FLAGS 					0x04
#define LCD_REG_CMD_REG					0x05
#define LCD_REG_NB_PARAM				0x06
#define LCD_REG_PARAM(index)+ index



void delay(){
	int c;
	for (c = 1; c <= 32767; c++){}
}

void lcd_flag_set (uint16_t flag){
	uint16_t reg_flag_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS, reg_flag_val | flag);
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS,flag);
}

void lcd_reset(){
	lcd_flag_set(0x04);
	uint16_t reg_flag_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	while( reg_flag_val & 0x04){
		reg_flag_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	}
}

void send_command(uint16_t cmd, uint16_t n, uint16_t* params)
{
	uint16_t index = 0;

	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_CMD_REG, cmd);
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_NB_PARAM, n);


	while(index < n){
		IOWR_16DIRECT(LCD_0_BASE, LCD_REG_PARAM(index), params[index]);
		++index;
	}

	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS, 0x2);
	uint16_t reg_flags = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	while(reg_flags & 0x2){
		reg_flags = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	}
	printf("command sent", (unsigned long)reg_flags,"\n");
}

void start_lcd(){
	lcd_flag_set(0x01);
	uint16_t reg_flags_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);

	while(reg_flags_val & 0x1){
		reg_flags_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	}
}
void init_lcd(){
	send_command(0x11, 0, (uint16_t []){ 0x09, 0x0a});
	send_command(0xcf, 3, (uint16_t []){ 0x0, 0x81, 0xc0});
	send_command(0xed, 4, (uint16_t []){ 0x64, 0x03, 0x12, 0x81});
	send_command(0xe8, 3, (uint16_t []){ 0x85, 0x01, 0x0798});
	send_command(0xcb, 5, (uint16_t []){ 0x39, 0x2c, 0x00, 0x34, 0x02});
	send_command(0xf7, 1, (uint16_t []){ 0x20});
	send_command(0xea, 2, (uint16_t []){ 0x00, 0x00});
	send_command(0xb1, 2, (uint16_t []){ 0x00, 0x1b});
	send_command(0xb6, 2, (uint16_t []){ 0x0a, 0xa2});
	send_command(0xc0, 1, (uint16_t []){ 0x05});
	send_command(0xc1, 1, (uint16_t []){ 0x11});
	send_command(0xc5, 2, (uint16_t []){ 0x45, 0x45});
	send_command(0xc7, 1, (uint16_t []){ 0xa2});
	send_command(0x36, 1, (uint16_t []){ 0x08}); //BGR (originally rgb with 0x48)
	send_command(0xf2, 1, (uint16_t []){ 0x00});
	send_command(0x26, 1, (uint16_t []){ 0x01});
	send_command(0xe0, 15, (uint16_t []){ 0xf, 0x26, 0x24, 0xb, 0xe, 0x8, 0x4b, 0xa8, 0x3b, 0x0a, 0x14, 0x06, 0x10, 0x09, 0x00});
	send_command(0xe1, 15, (uint16_t []){ 0x0, 0x1c, 0x20, 0x4, 0x10, 0x8, 0x34, 0x47, 0x44, 0x05, 0xb, 0x9, 0x2f, 0x36, 0x0f});
	send_command(0x2a, 4, (uint16_t []){ 0x0, 0x0, 0x0, 0xef});
	send_command(0x2b, 4, (uint16_t []){ 0x0, 0x0, 0x01, 0x3f});
	send_command(0x3a, 1, (uint16_t []){ 0x55}); //RGB
	send_command(0xf6, 3, (uint16_t []){ 0x01, 0x30, 0x0});
	send_command(0x29, 0, (uint16_t []){ 0x09, 0x0a});
	send_command(0x2c, 0, (uint16_t []){ 0x09, 0x0a});
}

void configure_image(uint32_t image_address, uint32_t image_size){
	uint16_t image_address_low = image_address & 0xFFFF;
	uint16_t image_address_high = (image_address >> 16) & 0xFFFF;
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_IMG_ADDRESS_LOW,image_address_low);
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_IMG_ADDRESS_HIGH,image_address_high);
	uint16_t image_size_low = image_size & 0xFFFF;
	uint16_t image_size_high = (image_size >> 16) & 0xFFFF;	
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_IMG_LENGTH_LOW, image_size_low);
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_IMG_LENGTH_HIGH, image_size_high);
}


void init_image(uint32_t image_address, uint32_t rows, uint32_t cols){
	uint32_t i = 0;
	uint16_t color = 0xF800;

	while(i < rows * sizeof(uint16_t))
	{
		uint32_t j = 0;
		if(i % 100 == 0)
			color = color == 0xF800 ? 0x001F : 0xF800;

		while(j < cols * sizeof(uint16_t))
		{
			IOWR_16DIRECT(image_address, i * cols + j, color);
			if(IORD_16DIRECT(image_address, i * cols + j) != color)
			{
				printf("Error writing to extender\n");
			}
			j += 2;
		}

		i += 2;
	}
}



int main(){
	
	
/*	while(1){
		IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS,0xFFFF);
		delay();
		uint16_t reg_flag_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
		printf("%lu", (unsigned long)reg_flag_val);
	}*/

	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS,0x0004);

	uint16_t reg_flag_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	printf("%lu", (unsigned long)reg_flag_val);

	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS,0x0000);

	//init lcd
	init_lcd();
	
	//img address register
	
	//img length register
	uint32_t image_address = HPS_0_BRIDGES_BASE;
	uint32_t image_size = 320 * 240 * sizeof(uint16_t);
	init_image(image_address, 240, 320);
	configure_image(image_address,image_size);
	//lcd enable 0xF800
	IOWR_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS,0x00000001);
	 reg_flag_val = IORD_16DIRECT(LCD_0_BASE, LCD_REG_FLAGS);
	printf("%lu", (unsigned long)reg_flag_val);

	printf("Display Stopped\n");
	return 0;
}
