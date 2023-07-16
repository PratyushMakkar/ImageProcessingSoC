#ifndef __GAME_STATE_H__
#define __GAME_STATE_H__

#include <utility>
#include <vector>
#include <stdint.h>

enum class GAME_STATE {
  PLAYING,
  RESUME
};

typedef struct {
  bool IsResumed;
  std::pair<uint16_t, uint16_t> dimensions;
  std::pair<uint16_t, uint16_t> ballPosition;
  std::pair<uint16_t, uint16_t> ballVelocity;
  std::pair<uint16_t, uint16_t> leftPaddlePosition;
  std::pair<uint16_t, uint16_t> rightPaddlePosition;
} GameState_t;

char* SerializeData(GameState_t &state);
GameState_t DeserializeData(std::vector<uint16_t> data);

#endif