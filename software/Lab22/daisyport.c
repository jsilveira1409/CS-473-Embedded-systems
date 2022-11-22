#include "daisyport.h"
#include "io.h"

void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (red << 16) | (green << 8) | blue;
	IOWR_32DIRECT(DAISY_REG_D1,0,color);
}

void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (red << 16) | (green << 8) | blue;
	IOWR_32DIRECT(DAISY_REG_D2,0,red);
}

void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (red << 16) | (green << 8) | blue;
	IOWR_32DIRECT(DAISY_REG_D3,0,red);
}

void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (red << 16) | (green << 8) | blue;
	IOWR_32DIRECT(DAISY_REG_D4,0,red);
}


void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (red << 16) | (green << 8) | blue;
	daisy_d1_set(red, green, blue);
	daisy_d2_set(red, green, blue);
	daisy_d3_set(red, green, blue);
	daisy_d4_set(red, green, blue);
}
