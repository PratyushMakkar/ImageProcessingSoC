#ifndef __GAME_STATE_H__
#define __GAME_STATE_H__

#include <utility>
#include <vector>
#include <stdint.h>

enum class GAME_STATE {
  PLAYING,
  RESUME
};

class GameState_t {
  public:
    GameState_t();
    std::vector<uint8_t> SerializeData();
    GameState_t DeserializeData(std::vector<uint8_t> data);
  private:
    bool IsResumed;
    std::pair<uint16_t, uint16_t> dimensions;
    std::pair<uint16_t, uint16_t> ballPosition;
    std::pair<uint8_t, uint8_t> ballVelocity;
    std::pair<uint16_t, uint16_t> leftPaddlePosition;
    std::pair<uint16_t, uint16_t> rightPaddlePosition;
};

#endif