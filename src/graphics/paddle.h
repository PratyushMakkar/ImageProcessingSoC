#ifndef PADDLE_H
#define PADDLE_H

#define DELTA_SCREEN 50
#define PADDLE_WIDTH 40u
#define PADDLE_HEIGHT 200u

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
    SDLApp* app;
    void RenderPaddle();
    PADDLE_TYPE type;
    double pos_y;
    SDL_Rect paddle;
};

#endif