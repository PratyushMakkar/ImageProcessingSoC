#include "playerScore.h"
#include <string> 
#include <iostream>

TTF_Font * PlayerScore::surface_font;

PlayerScore::PlayerScore(SDL_Renderer* render) {
  this->render = render;
  surface_font = TTF_OpenFont(FONT_PATH, 40);
  this->_score = std::pair<uint8_t, uint8_t>{0,1};
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
  std::string score1 = std::to_string(static_cast<int>(_score.first));
  std::string score2 = std::to_string(static_cast<int>(_score.second));

  SDL_Surface * surface = TTF_RenderText_Solid(PlayerScore::surface_font, const_cast<char*>(score1.c_str()), {0xFF, 0xFF, 0xFF, 0xFF});
  SDL_Surface * surface2 = TTF_RenderText_Solid(PlayerScore::surface_font, const_cast<char*>(score2.c_str()), {0xFF, 0xFF, 0xFF, 0xFF});

  if (!surface || !surface2) {
    std::cout << "SDLSurface: " << SDL_GetError() << std::endl;
  }

  SDL_Texture * texture = SDL_CreateTextureFromSurface(render, surface);
   SDL_Texture * texture2 = SDL_CreateTextureFromSurface(render, surface2);
  if (!texture || !texture2) {
    std::cout << SDL_GetError() <<std::endl;
  }

  SDL_Rect rect1 =  {
    .h = 30,
    .w = 30,
    .x = _SCREEN_WIDTH/4,
    .y = 10
  };

  SDL_Rect rect2 =  {
    .h = 30,
    .w = 30,
    .x = 3*_SCREEN_WIDTH/4,
    .y = 10
  };

  if (SDL_RenderCopy(this->render, texture, nullptr, &rect1) !=0 || SDL_RenderCopy(this->render, texture2, nullptr, &rect2) )  {
    std::cout<< SDL_GetError() <<std::endl;
  }
}