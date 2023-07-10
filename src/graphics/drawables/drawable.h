#ifndef __DRAWABLE_H__
#define __DRAWABLE_H__

#include <vector>
#include "SDL2/SDL.h"

extern int _SCREEN_WIDTH;
extern int _SCREEN_HEIGHT;

class Drawable {
  protected:
    SDL_Renderer* render;
    SDL_Rect paddle;
    std::vector<float> position = {};
    
  public:
    Drawable() {};
    virtual ~Drawable() = default;
    virtual void Draw() {};
    std::vector<float> GetPos();
};

#endif