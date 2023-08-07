#ifndef __TIMER_H__
#define __TIMER_H__

#include <stdint.h>
#include <stdbool.h>

#include <error_defs.h>

#define TIM_BASE_ADDRESS ((uint32_t) 0xA0000000)

#define PRESCALER_0  ((uint32_t) 0x00)
#define PRESCALER_1  ((uint32_t) 0x01 << 0U)
#define PRESCALER_2  ((uint32_t) 0x01 << 1U)
#define PRESCALER_4  ((uint32_t) 0x01 << 3U)
#define PRESCALER_8  ((uint32_t) 0x01 << 7U)
#define PRESCALER_16 ((uint32_t) 0x01 << 15U)
#define PRESCALER_32 ((uint32_t) 0x01 << 31U)

#define TIM1 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x00 << 4U)))
#define TIM2 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x01 << 4U)))
#define TIM3 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x02 << 4U)))
#define TIM4 ((volatile timer_t*) (TIM_BASE_ADDRESS + (0x03 << 4U)))

#define TIM_CFG_DEFAULT = 0x0010U

typedef enum {
  ENABLE_COUNTER      = (0x0001U << 0U),
  ENABLE_INTERRUPT    = (0x0001U << 1U),
  AUTOMATIC_RESET     = (0x0001U << 2U),
  REINITALIZE_COUNTER = (0x0001U << 3U),
  CLEAR_TIMER         = (0x0001U << 4U),
  TIMER_DID_EXPIRE    = (0x0001U << 5U)
} config_mask_t;

typedef struct {
  uint16_t config;    // 0x00  Configuration and flags for the timer instance. 
  uint32_t timerCnt;  // 0x04  The timer value for the timer
  uint32_t compare;   // 0x08  The upper bound for the counter
  uint32_t prescaler; // 0x0C  The prescaler value
} timer_t;

error_codes_t initalizeTimer(timer_t* timer);

error_codes_t getTimerCount(const timer_t* timer, uint32_t* time);
error_codes_t getPrescalerValue(const timer_t* timer, uint32_t* prescaler);
error_codes_t getCompareValue(const timer_t* timer, uint32_t* cmp);
error_codes_t timerDidExpire(const timer_t* timer, bool* returnBool);

error_codes_t enableTimerConfig(timer_t* timer, config_mask_t mask);
error_codes_t disableTimerConfig(timer_t* timer, config_mask_t mask);

error_codes_t setPrescalerValue(timer_t* timer, uint32_t prescaler);
error_codes_t setComapreValue(timer_t* timer, uint32_t cmp);
error_codes_t clearTimer(timer_t* timer);

#endif