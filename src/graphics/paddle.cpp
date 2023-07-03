#include "paddle.h"

float Paddle::getPosY() {
  return this->pos_y;
}

Paddle::Paddle(PADDLE_TYPE m_type) {
  this->type = m_type;
}

Paddle::~Paddle() {}

void Paddle::InputHandler(const SDL_Event &event) {
  
}

void Paddle::RenderPaddle(SDL_Renderer* render) {

}

