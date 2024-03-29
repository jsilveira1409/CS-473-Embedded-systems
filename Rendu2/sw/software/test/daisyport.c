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

void daisy_d5_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D5_OFFSET,color);
}

void daisy_d6_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D6_OFFSET,color);
}

void daisy_d7_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D7_OFFSET,color);
}

void daisy_d8_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D8_OFFSET,color);
}

void daisy_d9_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D9_OFFSET,color);
}

void daisy_d10_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D10_OFFSET,color);
}

void daisy_d11_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D11_OFFSET,color);
}
void daisy_d12_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D12_OFFSET,color);
}

void daisy_d13_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D13_OFFSET,color);
}
void daisy_d14_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D14_OFFSET,color);
}

void daisy_d15_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D15_OFFSET,color);
}

void daisy_d16_set(uint8_t red, uint8_t green, uint8_t blue){
	uint32_t color = (blue << 16) | (red << 8) | green;
	IOWR_32DIRECT(DAISY_BASE_ADDRESS,4 * DAISY_REG_D16_OFFSET,color);
}

void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue){
	daisy_d1_set(red, green, blue);
	daisy_d2_set(red, green, blue);
	daisy_d3_set(red, green, blue);
	daisy_d4_set(red, green, blue);
	daisy_d5_set(red, green, blue);
	daisy_d6_set(red, green, blue);
	daisy_d7_set(red, green, blue);
	daisy_d8_set(red, green, blue);
	daisy_d9_set(red, green, blue);
	daisy_d10_set(red, green, blue);
	daisy_d11_set(red, green, blue);
	daisy_d12_set(red, green, blue);
	daisy_d13_set(red, green, blue);
	daisy_d14_set(red, green, blue);
	daisy_d15_set(red, green, blue);
	daisy_d16_set(red, green, blue);
}


void daisy_rainbow(){
	daisy_d1_set(254, 0, 0);
	daisy_d2_set(254, 125, 0);
	daisy_d3_set(254, 254, 0);
	daisy_d4_set(125, 254, 0);
	daisy_d5_set(0, 254, 0);
	daisy_d6_set(0, 254, 120);
	daisy_d7_set(0, 254, 254);
	daisy_d8_set(0, 125, 254);
	daisy_d9_set(0, 0, 254);
	daisy_d10_set(125, 0, 254);
	daisy_d11_set(254, 0, 254);
	daisy_d12_set(254, 0, 125);
	daisy_d13_set(254, 0, 200);
	daisy_d14_set(200, 0, 220);
	daisy_d15_set(100, 0, 230);
	daisy_d16_set(0, 0, 254);
}
