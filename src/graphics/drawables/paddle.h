#ifndef PADDLE_H
#define PADDLE_H

#define DELTA_SCREEN 50
#define PADDLE_WIDTH 12
#define SCREEN_PADDING 10
#define PADDLE_HEIGHT 100

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
    virtual void Draw() override;
    virtual void handleInput(const SDL_Event &e) override;
};

#endif