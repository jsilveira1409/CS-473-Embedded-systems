#ifndef 		DAISYPORT_H
#define 		DAISYPORT_H
#include "stdint.h"
#include "system.h"

#define 		DAISY_BASE_ADDRESS 	DAISY_0_BASE
#define			DAISY_REG_D1_OFFSET		0X01
#define			DAISY_REG_D2_OFFSET		0X02
#define			DAISY_REG_D3_OFFSET		0X03
#define			DAISY_REG_D4_OFFSET		0X04
#define 		DAISY_REG_ENABLE_OFFSET		0X04
void daisy_enable(uint32_t enable);
void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue);

#endif