#include "gameState.h"
#include <vector>

char* SerializeData(GameState_t &data) {
  char* buffer = new char[sizeof(data)];
  memcpy(buffer, &data, sizeof(data));
  return buffer;
}

GameState_t DeserializeData(char *address) {
  GameState_t state{};
  memcpy(&state, address, sizeof(state));
  return state;
}

