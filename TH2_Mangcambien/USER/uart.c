#include "uart.h"
#include "stm32f10x.h"
#include <stdio.h>
#include <string.h>

void USART_InitConfig(void) {
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1 | RCC_APB2Periph_GPIOA, ENABLE);

    GPIO_InitTypeDef gpioInitStructure;

    gpioInitStructure.GPIO_Pin = GPIO_Pin_9;
    gpioInitStructure.GPIO_Mode = GPIO_Mode_AF_PP;
    gpioInitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOA, &gpioInitStructure);

    gpioInitStructure.GPIO_Pin = GPIO_Pin_10;
    gpioInitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;
    GPIO_Init(GPIOA, &gpioInitStructure);

    USART_InitTypeDef usartInitStructure;
    usartInitStructure.USART_BaudRate = 9600;
    usartInitStructure.USART_WordLength = USART_WordLength_8b;
    usartInitStructure.USART_StopBits = USART_StopBits_1;
    usartInitStructure.USART_Parity = USART_Parity_No;
    usartInitStructure.USART_Mode = USART_Mode_Tx;
    usartInitStructure.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
    USART_Init(USART1, &usartInitStructure);

    USART_Cmd(USART1, ENABLE);
}

void USART_SendText(char *text) {
    while (*text) {
        USART_SendData(USART1, *text++);
        while (USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET);
    }
}

void USART_SendValue(uint8_t value) {
    char buffer[5];
    sprintf(buffer, "%d", value);
    USART_SendText(buffer);
}
