#ifndef 		DAISYPORT_H
#define 		DAISYPORT_H
#include "stdint.h"
#include "system.h"

#define 		DAISY_BASE_ADDRESS 	DAISY_0_BASE
#define			DAISY_REG_D1_OFFSET			0X00
#define			DAISY_REG_D2_OFFSET			0X01
#define			DAISY_REG_D3_OFFSET			0X02
#define			DAISY_REG_D4_OFFSET			0X03
#define			DAISY_REG_D5_OFFSET			0X04
#define			DAISY_REG_D6_OFFSET			0X05
#define			DAISY_REG_D7_OFFSET			0X06
#define			DAISY_REG_D8_OFFSET			0X07
#define			DAISY_REG_D9_OFFSET			0X08
#define			DAISY_REG_D10_OFFSET		0X09
#define			DAISY_REG_D11_OFFSET		0X0A
#define			DAISY_REG_D12_OFFSET		0X0B
#define			DAISY_REG_D13_OFFSET		0X0C
#define			DAISY_REG_D14_OFFSET		0X0D
#define			DAISY_REG_D15_OFFSET		0X0E
#define			DAISY_REG_D16_OFFSET		0X0F

void daisy_rainbow();
void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d5_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d6_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d7_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d8_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d9_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d10_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d11_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d12_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d13_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d14_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d15_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d16_set(uint8_t red, uint8_t green, uint8_t blue);

#endif