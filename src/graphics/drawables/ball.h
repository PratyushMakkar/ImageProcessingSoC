#ifndef __BALL_H__
#define __BALL_H__

#include "drawable.h"

#define BALL_WIDTH 12
#define BALL_HEIGHT 12

class Ball : public Drawable {
  public:
    Ball(SDL_Renderer* render);
    virtual void Draw() override;
    virtual void handleInput(const SDL_Event &e) override;
};

#endif