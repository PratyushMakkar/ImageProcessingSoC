#include "ball.h"
#include <iostream>

Ball::Ball(SDL_Renderer* render) {
  this->render = render;
  this->position = std::pair<int, int> {_SCREEN_HEIGHT/2, _SCREEN_WIDTH/2};
}

void Ball::Draw() {
  SDL_SetRenderDrawColor(render, 255, 255, 255, 255);
  this->paddle = SDL_Rect {
        .h = BALL_HEIGHT,
        .y = position.first,
        .x = position.second,
        .w = BALL_WIDTH,
  };
  if (SDL_RenderFillRect(render, &this->paddle) != 0) {
    std::cout<< "Failed to render ball \n";
  }
}

void Ball::handleInput(const SDL_Event &e) {
  this->Draw();
}