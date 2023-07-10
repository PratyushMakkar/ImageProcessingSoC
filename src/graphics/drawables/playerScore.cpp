#include "playerScore.h"
#include "iostream"

PlayerScore::PlayerScore(SDL_Renderer* render) {
  this->render = render;
  
  TTF_Font * surface_font = TTF_OpenFont("DejaVuSansMono.ttf", 40);
  SDL_Surface * surface = TTF_RenderText_Solid(surface_font, "0", {0xFF, 0xFF, 0xFF, 0xFF});
  SDL_Texture* texture = SDL_CreateTextureFromSurface(this->render, surface);

  int width, height;
  SDL_QueryTexture(texture, nullptr, nullptr, &width, &height);

  this->paddle = SDL_Rect {
    .h = 100,
    .w = 100,
    .x = 100,
    .y = 100
  };

  SDL_RenderCopy(this->render, texture, nullptr, &this->paddle);
  this->_score = std::pair<uint8_t, uint8_t>{0,0};
}

void PlayerScore::UpdateScore(PADDLE_TYPE type) {
  switch(type) {
    case (PADDLE_TYPE::LEFT):
      ++_score.first;
    case (PADDLE_TYPE::RIGHT):
      ++_score.second;
  }
}

void PlayerScore::Draw() {
  
}