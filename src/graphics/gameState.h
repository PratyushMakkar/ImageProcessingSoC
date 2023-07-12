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
    std::pair<int, int> dimensions;
    std::pair<int, int> ballPosition;
    std::pair<int, int> ballVelocity;
    std::pair<int, int> leftPaddlePosition;
    std::pair<int, int> rightPaddlePosition;
};

#endif