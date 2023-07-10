#include "paddle.h"
#include <iostream>

void Paddle::Draw() {
  SDL_Renderer* render = this->render;
  SDL_SetRenderDrawColor(render, 255, 255, 255, 255);
  if (SDL_RenderFillRect(render, &this->paddle) != 0) {
    std::cout<< "Failed to render paddle \n";
  }
}

Paddle::Paddle(PADDLE_TYPE m_type, SDL_Renderer* render) {
  this->render = render;
  this->type = m_type;

  switch (m_type) {
    case (PADDLE_TYPE::LEFT):
      this->paddle = SDL_Rect {
        .h = PADDLE_HEIGHT,
        .y = (_SCREEN_HEIGHT-PADDLE_HEIGHT)/2,
        .x = SCREEN_PADDING,
        .w = PADDLE_WIDTH,
      };
      break;
    case (PADDLE_TYPE::RIGHT):
      this->paddle = SDL_Rect {
        .h = PADDLE_HEIGHT,
        .y = (_SCREEN_HEIGHT-PADDLE_HEIGHT)/2,
        .x = (_SCREEN_WIDTH-PADDLE_WIDTH)-SCREEN_PADDING,
        .w = PADDLE_WIDTH,
      };
      break;
  }
}

Paddle::~Paddle() {}

void Paddle::InputHandler(const SDL_Event &event) {
  this->Draw();
}

