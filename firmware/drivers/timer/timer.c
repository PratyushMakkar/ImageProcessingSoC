#include <timer.h>
#include <error_defs.h>

static inline bool isValidTimer(const timer_t* timer);
static inline bool isValidPrescaler(uint32_t prescaler);

error_codes_t timerDidExpire(const timer_t* timer, bool* returnBool) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  *returnBool = timer->config & TIMER_DID_EXPIRE;
  return ERR_CODE_SUCCESS;
}

error_codes_t clearTimer(timer_t* timer) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  error_codes_t errCode;
  RETURN_IF_ERROR_CODE(enableTimerConfig(timer, CLEAR_TIMER));
  return ERR_CODE_SUCCESS;
}

error_codes_t enableTimerConfig(timer_t* timer, config_mask_t mask) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  timer->config |= mask;
  return ERR_CODE_SUCCESS;
}

error_codes_t disableTimerConfig(timer_t* timer, config_mask_t mask) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  timer->config &= (~mask);
  return ERR_CODE_SUCCESS;
}

error_codes_t getTimerCount(const timer_t* timer, uint32_t* time) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  *time = timer->timerCnt;
  return ERR_CODE_SUCCESS;
}

error_codes_t getPrescalerValue(const timer_t* timer, uint32_t* prescaler) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  *prescaler = timer->prescaler;
  return ERR_CODE_SUCCESS;
}

error_codes_t getCompareValue(const timer_t* timer, uint32_t* cmp) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  *cmp = timer->compare;
  return ERR_CODE_SUCCESS;
}

error_codes_t setPrescalerValue(timer_t* timer, uint32_t prescaler) {
  if (!isValidPrescaler(prescaler)) return TIM_INVALID_PRESCALER;
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;

  timer->prescaler = prescaler;
  return ERR_CODE_SUCCESS;
}

error_codes_t setComapreValue(timer_t* timer, uint32_t cmp) {
  if (!isValidTimer(timer)) return TIM_INVALID_INSTANCE;
  timer->compare = cmp;
  return ERR_CODE_SUCCESS;
}

static inline bool isValidPrescaler(uint32_t prescaler) {
  return ((prescaler == PRESCALER_0)
      || (prescaler == PRESCALER_1)
      || (prescaler == PRESCALER_2)
      || (prescaler == PRESCALER_4)
      || (prescaler == PRESCALER_8)
      || (prescaler == PRESCALER_16)
      || (prescaler == PRESCALER_32));
}
static inline bool isValidTimer(const timer_t* timer) {
  return ((timer == TIM1)
    || (timer == TIM2)
    || (timer == TIM3)
    || (timer == TIM4));
}