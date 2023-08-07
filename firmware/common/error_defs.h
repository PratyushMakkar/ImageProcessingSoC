#ifndef __ERROR_DEFS_H__
#define __ERROR_DEFS_H__

#define RETURN_IF_ERROR_CODE(_ret)         \
  do {                                     \
    errCode = _ret;                        \
    if (errCode != ERR_CODE_SUCCESS) {     \
      return errCode;                      \
    }                                      \
  } while (0)

typedef enum {
  ERR_CODE_SUCCESS = 0x00,

  TIM_INVALID_INSTANCE = 0x01,
  TIM_INVALID_PRESCALER = 0x02
} error_codes_t;

#endif