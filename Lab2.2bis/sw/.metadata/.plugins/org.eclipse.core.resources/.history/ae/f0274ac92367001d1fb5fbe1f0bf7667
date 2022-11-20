#ifndef 		DAISYPORT_H
#define 		DAISYPORT_H
#include "stdint.h"

#define 		DAISY_BASE_ADDRESS 	0x00040000
#define			DAISY_REG_ENABLE	DAISY_BASE_ADDRESS + 0X01
#define			DAISY_REG_D1_GREEN	DAISY_BASE_ADDRESS + 0X02
#define			DAISY_REG_D1_RED	DAISY_BASE_ADDRESS + 0X03
#define			DAISY_REG_D1_BLUE	DAISY_BASE_ADDRESS + 0X04
#define			DAISY_REG_D2_GREEN	DAISY_BASE_ADDRESS + 0X05
#define			DAISY_REG_D2_RED	DAISY_BASE_ADDRESS + 0X06
#define			DAISY_REG_D2_BLUE	DAISY_BASE_ADDRESS + 0X07
#define			DAISY_REG_D3_GREEN	DAISY_BASE_ADDRESS + 0X08
#define			DAISY_REG_D3_RED	DAISY_BASE_ADDRESS + 0X09
#define			DAISY_REG_D3_BLUE	DAISY_BASE_ADDRESS + 0X0A
#define			DAISY_REG_D4_GREEN	DAISY_BASE_ADDRESS + 0X0B
#define			DAISY_REG_D4_RED	DAISY_BASE_ADDRESS + 0X0C
#define			DAISY_REG_D4_BLUE	DAISY_BASE_ADDRESS + 0X0D
#define			DAISY_REG_Q			DAISY_BASE_ADDRESS + 0X0E
#define			DAISY_REG_TMP		DAISY_BASE_ADDRESS + 0X0F


void daisy_enable();
void daisy_disable();
void daisy_all_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d1_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d2_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d3_set(uint8_t red, uint8_t green, uint8_t blue);
void daisy_d4_set(uint8_t red, uint8_t green, uint8_t blue);

#endif
