#ifndef PADDLE_H
#define PADDLE_H

#define DELTA_SCREEN 50
#include "defs.h"
 
enum class PADDLE_TYPE {
  LEFT,
  RIGHT
};

class Paddle {
  public:
  Paddle(PADDLE_TYPE type);
  ~Paddle();
  void InputHandler(const SDL_Event &event);
  float getPosY();

  private:
    void RenderPaddle(SDL_Renderer* render);
    PADDLE_TYPE type;
    double pos_y;
};

#endif