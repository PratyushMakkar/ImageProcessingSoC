#include "gameState.h"
#include <vector>

std::vector<uint8_t> GameState_t::SerializeData() {
  return std::vector<uint8_t>{};
}

GameState_t GameState_t::DeserializeData(std::vector<uint8_t> data) {
  return GameState_t{};
}

GameState_t::GameState_t() {
  
}