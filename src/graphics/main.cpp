#include <iostream>
#include <SDL2/SDL.h>

#include "defs.h"
#include "paddle.h"

int main(int agrc, char** argv) {
  if (SDL_Init(SDL_INIT_VIDEO) < 0) {
    std::cout << "Failed to initialize the SDL2 library\n";
  }

  SDL_Window* window = nullptr;
  SDL_Renderer* render = nullptr;

  SDL_CreateWindowAndRenderer(680, 480, SDL_WINDOW_RESIZABLE,
  &window, &render);

  if (!window) {
    std::cout << "Failed to create window\n";
  }

  SDL_Surface *window_surface = SDL_GetWindowSurface(window);
  if (!window_surface) {
    std::cout << "Failed to get the surface from the window \n";
  }

  SDL_UpdateWindowSurface(window);
  SDL_Delay(5000);

  SDLApp app = {window_surface, window};
  Paddle left_paddle{PADDLE_TYPE::LEFT};
  Paddle right_paddle{PADDLE_TYPE::RIGHT};

  SDL_Event event;
  bool quit = false;

  while (!quit) {
    if (SDL_PollEvent(&event)) {
      switch (event.type) {
        case SDL_QUIT:
          quit = true;
        default:
          left_paddle.InputHandler(event);
          right_paddle.InputHandler(event);
      }      
    }
  }
}