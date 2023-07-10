#ifndef __DRAWABLE_H__
#define __DRAWABLE_H__


#include <utility>
#include "SDL2/SDL.h"

extern int _SCREEN_WIDTH;
extern int _SCREEN_HEIGHT;

class Drawable {
  protected:
    SDL_Renderer* render;
    SDL_Rect paddle;
    std::pair<int, int> position = {};
    
  public:
    Drawable() {};
    virtual ~Drawable() = default;
    virtual void Draw() {};
    virtual void handleInput(const SDL_Event &e) {};
    std::pair<int, int> GetPos();
};

#endif