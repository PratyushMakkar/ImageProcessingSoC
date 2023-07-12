#ifndef __BALL_H__
#define __BALL_H__

#include "drawable.h"

#define BALL_WIDTH 12
#define BALL_HEIGHT 12

class Ball : public Drawable {
  public:
    Ball(SDL_Renderer* render);
    void setVelocity(std::pair<int, int> velocity);
    std::pair<int, int> getVelocity();
    virtual void Draw() override;
    virtual void handleInput(const SDL_Event &e) override;
  private:
    std::pair<int, int> velocity;
};

#endif