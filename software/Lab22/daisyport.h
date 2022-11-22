#ifndef 		DAISYPORT_H
#define 		DAISYPORT_H
#include "stdint.h"

#define 		DAISY_BASE_ADDRESS 	0x00041000
#define			DAISY_REG_D1		DAISY_BASE_ADDRESS + 0X01
#define			DAISY_REG_D2		DAISY_BASE_ADDRESS + 0X02
#define			DAISY_REG_D3		DAISY_BASE_ADDRESS + 0X03
#define			DAISY_REG_D4		DAISY_BASE_ADDRESS + 0X04

void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue);

#endif