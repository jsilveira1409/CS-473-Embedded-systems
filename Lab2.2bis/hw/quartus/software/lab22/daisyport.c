#include "daisyport.h"
#include "io.h"


void daisy_enable(){
	uint8_t data = 0x11;
	IOWR_8DIRECT(DAISY_REG_ENABLE,0,data);
}

void daisy_disable(){

}

void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue){
	IOWR_8DIRECT(DAISY_REG_D1_RED,0,red);
	IOWR_8DIRECT(DAISY_REG_D1_GREEN,0,green);
	IOWR_8DIRECT(DAISY_REG_D1_BLUE,0,blue);
}

void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue){
	IOWR_8DIRECT(DAISY_REG_D2_RED,0,red);
	IOWR_8DIRECT(DAISY_REG_D2_GREEN,0,green);
	IOWR_8DIRECT(DAISY_REG_D2_BLUE,0,blue);
}

void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue){
	IOWR_8DIRECT(DAISY_REG_D3_RED,0,red);
	IOWR_8DIRECT(DAISY_REG_D3_GREEN,0,green);
	IOWR_8DIRECT(DAISY_REG_D3_BLUE,0,blue);
}

void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue){
	IOWR_8DIRECT(DAISY_REG_D4_RED,0,red);
	IOWR_8DIRECT(DAISY_REG_D4_GREEN,0,green);
	IOWR_8DIRECT(DAISY_REG_D4_BLUE,0,blue);
}


void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue){
	daisy_d1_set(red,green,blue);
	daisy_d2_set(red,green,blue);
	daisy_d3_set(red,green,blue);
	daisy_d4_set(red,green,blue);
}
