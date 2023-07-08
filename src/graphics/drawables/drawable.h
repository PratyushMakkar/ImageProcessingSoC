#ifndef __DRAWABLE_H__
#define __DRAWABLE_H__

#include <vector>
#include "SDL2/SDL.h"

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