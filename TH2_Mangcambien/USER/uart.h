#ifndef UART_H
#define UART_H

#include "stm32f10x.h"

void USART_InitConfig(void);

void USART_SendText(char *text);

void USART_SendValue(uint8_t value);

#endif 
