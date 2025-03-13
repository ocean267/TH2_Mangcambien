#include "dht11.h"
#include "delays.h"

uint8_t DHT11_ReadData(uint8_t *temperature, uint8_t *humidity) {
    uint16_t timerValue;
    uint8_t dataBuffer[5] = {0, 0, 0, 0, 0};
    uint8_t checksum;
    uint8_t i, j;

    GPIO_ResetBits(GPIOB, GPIO_Pin_12);
    Delay_ms(20);
    GPIO_SetBits(GPIOB, GPIO_Pin_12);

    TIM_SetCounter(TIM2, 0);
    while (TIM_GetCounter(TIM2) < 10) {
        if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12)) {
            break;
        }
    }
    timerValue = TIM_GetCounter(TIM2);
    if (timerValue >= 10) {
        return 1; 
    }

    TIM_SetCounter(TIM2, 0);
    while (TIM_GetCounter(TIM2) < 45) {
        if (!GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12)) {
            break;
        }
    }
    timerValue = TIM_GetCounter(TIM2);
    if ((timerValue >= 45) || (timerValue <= 5)) {
        return 2; 
    }

    TIM_SetCounter(TIM2, 0);
    while (TIM_GetCounter(TIM2) < 90) {
        if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12)) {
            break;
        }
    }
    timerValue = TIM_GetCounter(TIM2);
    if ((timerValue >= 90) || (timerValue <= 70)) {
        return 3; 
    }

    TIM_SetCounter(TIM2, 0);
    while (TIM_GetCounter(TIM2) < 95) {
        if (!GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12)) {
            break;
        }
    }
    timerValue = TIM_GetCounter(TIM2);
    if ((timerValue >= 95) || (timerValue <= 75)) {
        return 4; 
    }

    for (i = 0; i < 5; i++) {
        for (j = 0; j < 8; j++) {
            TIM_SetCounter(TIM2, 0);
            while (TIM_GetCounter(TIM2) < 65) {
                if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12)) {
                    break;
                }
            }
            timerValue = TIM_GetCounter(TIM2);
            if ((timerValue >= 65) || (timerValue <= 45)) {
                return 5; 
            }
            TIM_SetCounter(TIM2, 0);
            while (TIM_GetCounter(TIM2) < 80) {
                if (!GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_12)) {
                    break;
                }
            }
            timerValue = TIM_GetCounter(TIM2);
            if ((timerValue >= 80) || (timerValue <= 10)) {
                return 6; 
            }
            dataBuffer[i] <<= 1;
            if (timerValue > 45) {
                dataBuffer[i] |= 1;
            } else {
                dataBuffer[i] &= ~1;
            }
        }
    }

    checksum = dataBuffer[0] + dataBuffer[1] + dataBuffer[2] + dataBuffer[3];
    if (checksum != dataBuffer[4]) {
        return 7; 
    }

    *humidity = dataBuffer[0];
    *temperature = dataBuffer[2];
    return 0; 
}

void DHT11_Init(void) {
    RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);

    GPIO_InitTypeDef gpioInitStructure;
    gpioInitStructure.GPIO_Pin = GPIO_Pin_12;
    gpioInitStructure.GPIO_Mode = GPIO_Mode_Out_OD;
    gpioInitStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOB, &gpioInitStructure);
}
