#ifndef APP_DEFS_H
#define APP_DEFS_H

#define SCREEN_WIDTH   1280
#define SCREEN_HEIGHT 720
#define INDEX(type) (type == PADDLE_TYPE::LEFT) ? 0 : 1;

#include <SDL2/SDL.h>
#include <iostream>
#include <vector>
#include "drawables/paddle.h"

enum class GAME_STATE {
  PLAYING,
  RESUME
};

class SDLApp {
  private:
    GAME_STATE _state;
    std::vector<Drawable*> drawables;
    SDL_Renderer** render_ptr;
    SDL_Window** window_ptr;

  public:
    SDLApp(SDL_Window* &window, SDL_Renderer* &render);
    ~SDLApp();
    void InsertPaddle(Paddle* paddle);
    Paddle* GetPaddle(PADDLE_TYPE m_type);
    void handleInput(SDL_Event &e);
    void prepareScene();
    void presentScene();
};

#endif