#ifndef DHT11_H
#define DHT11_H

#include "stm32f10x.h"

void DHT11_Init(void);


uint8_t DHT11_ReadData(uint8_t *temperature, uint8_t *humidity);

#endif 
