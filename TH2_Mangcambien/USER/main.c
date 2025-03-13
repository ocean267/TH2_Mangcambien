#include "stm32f10x.h"
#include "dht11.h"
#include "uart.h"
#include "delays.h"


void Timer_Init(void) {
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);

    TIM_TimeBaseInitTypeDef timerInitStructure;
    timerInitStructure.TIM_Period = 0xFFFF;
    timerInitStructure.TIM_Prescaler = 72 - 1;  
    timerInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
    TIM_TimeBaseInit(TIM2, &timerInitStructure);
    TIM_Cmd(TIM2, ENABLE);
}

int main(void) {
    uint8_t temperature = 0;
    uint8_t humidity = 0;
    uint8_t error;

    // Kh?i t?o các module
    DHT11_Init();
    USART_InitConfig();
    Timer_Init();

    while (1) {
        error = DHT11_ReadData(&temperature, &humidity);
        if (error == 0) {
            USART_SendText("Temperature: ");
            USART_SendValue(temperature);
            USART_SendText(" *C\n");
            USART_SendText("Humidity: ");
            USART_SendValue(humidity);
            USART_SendText(" %\n");
        } else {
            USART_SendText("Error reading DHT11: ");
            USART_SendValue(error);
            USART_SendText("\n");
        }
        Delay_ms(1000);  
    }
}
