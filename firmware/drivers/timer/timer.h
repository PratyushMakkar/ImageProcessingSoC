#ifndef __TIMER_H__
#define __TIMER_H__

#include <stdint.h>
#include <stdbool.h>

#define TIM_BASE_ADDRESS ((uint32_t) 0xFFFFFFF)

#define PRESCALER_0  ((uint32_t) 0x00)
#define PRESCALER_1  ((uint32_t) 0x01 << 0U)
#define PRESCALER_2  ((uint32_t) 0x01 << 1U)
#define PRESCALER_4  ((uint32_t) 0x01 << 3U)
#define PRESCALER_8  ((uint32_t) 0x01 << 7U)
#define PRESCALER_16 ((uint32_t) 0x01 << 15U)
#define PRESCALER_32 ((uint32_t) 0x01 << 31U)

#define TIM_CFG ((volatile timer_config_t*) (TIM_BASE_ADDRESS))

#define TIM1 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x01 << 5U)))
#define TIM2 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x02 << 5U)))
#define TIM3 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x03 << 5U)))
#define TIM4 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x04 << 5U)))

typedef struct {
  uint8_t configRegister;     // 0x00
  uint32_t timerCnt;          // 0x04  The timer value for the timer
  uint32_t compareRegister;   // 0x08  The upper bound for the counter
  uint32_t prescaler;         // 0x0C  The prescaler value
  uint32_t flagRegister;      // 0x10  Flag register for the counter.
} timer_t;

error_codes_t getTimerCount(const timer_t* timer, uint32_t* time);
error_codes_t getPrescalerValue(const timer_t* timer, uint32_t* prescaler);
error_codes_t getCompareValue(const timer_t* timer, uint32_t* cmp);

error_codes_t setPrescalerValue(timer_t* timer, uint32_t prescaler);
error_codes_t setComapreValue(timer_t* timer, uint32_t cmp);

#endif