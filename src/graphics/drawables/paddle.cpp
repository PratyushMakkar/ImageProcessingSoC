#include "paddle.h"

void Paddle::Draw() {
  SDL_Renderer* render = this->render;
  SDL_RenderClear(render);
  SDL_SetRenderDrawColor(render, 255, 255, 255, 255);
  SDL_RenderDrawRect(render, &(this->paddle));
  SDL_SetRenderDrawColor(render, 0, 0, 0, 255);
  SDL_RenderFillRect(render, &(this->paddle));
  SDL_RenderPresent(render);
}

Paddle::Paddle(PADDLE_TYPE m_type, SDL_Renderer* render) {
  this->render = render;
  this->type = m_type;

  switch (m_type) {
    case (PADDLE_TYPE::LEFT):
      this->paddle = SDL_Rect {
        .h = PADDLE_HEIGHT,
        .y = 0,
        .x = 0,
        .w = PADDLE_WIDTH,
      };
      break;
    case (PADDLE_TYPE::RIGHT):
      this->paddle = SDL_Rect {
        .h = PADDLE_HEIGHT,
        .y = 0,
        .x = 0,
        .w = PADDLE_WIDTH,
      };
      break;
  }
}

Paddle::~Paddle() {}

void Paddle::InputHandler(const SDL_Event &event) {
  this->Draw();
}

