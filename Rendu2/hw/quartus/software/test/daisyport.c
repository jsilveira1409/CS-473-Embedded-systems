#include "daisyport.h"
#include "io.h"

void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D1_OFFSET,color);
}

void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D2_OFFSET,color);
}

void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D3_OFFSET,color);
}

void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D4_OFFSET,color);
}


void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue){
	daisy_d1_set(red, green, blue);
	daisy_d2_set(red, green, blue);
	daisy_d3_set(red, green, blue);
	daisy_d4_set(red, green, blue);
}


void daisy_enable(uint32_t enable){
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_ENABLE_OFFSET,enable);
}