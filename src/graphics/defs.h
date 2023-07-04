
#ifndef APP_DEFS_H
#define APP_DEFS_H

#define SCREEN_WIDTH   1280
#define SCREEN_HEIGHT 720

#include <SDL2/SDL.h>
#include <iostream>

class SDLApp {
  private:
    SDL_Surface* window_surface_ptr;
    SDL_Window* window_ptr;

  public:
    SDL_Renderer* render_ptr;
    SDLApp(SDL_Surface *window_surface_ptr, SDL_Window* window_ptr);
    ~SDLApp();
    void prepareScene();
    void presentScene();
};

#endif