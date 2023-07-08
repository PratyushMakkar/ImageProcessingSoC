#ifndef PADDLE_H
#define PADDLE_H

#define DELTA_SCREEN 50u
#define PADDLE_WIDTH 40u
#define PADDLE_HEIGHT 200u

#include "drawable.h"
 
enum class PADDLE_TYPE {
  LEFT,
  RIGHT
};

class Paddle : public Drawable {
  public:
    PADDLE_TYPE type;
    Paddle(PADDLE_TYPE type, SDL_Renderer* render);
    ~Paddle();
    void InputHandler(const SDL_Event &event);
    virtual void Draw() override;
};

#endif