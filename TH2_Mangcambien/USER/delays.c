#include "delays.h"
#include "stm32f10x_tim.h"

void Delay_us(uint32_t delay) {
    TIM_SetCounter(TIM2, 0);
    while (TIM_GetCounter(TIM2) < delay);
}

void Delay_ms(uint32_t delay) {
    while (delay--) {
        Delay_us(1000);
    }
}
