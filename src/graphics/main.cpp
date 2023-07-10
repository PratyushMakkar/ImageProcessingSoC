#include <iostream>
#include <SDL2/SDL.h>

#include "defs.h"
#include "drawables/paddle.h"
#include "drawables/playerScore.h"

int _SCREEN_WIDTH{700};
int _SCREEN_HEIGHT{400};

int main(int agrc, char** argv) {
  SDL_Window* window = nullptr;
  SDL_Renderer* render = nullptr;
  SDL_Surface* window_surface = nullptr;

  SDLApp app{window, render};
  app.prepareScene();
  app.presentScene();

  Paddle left_paddle{PADDLE_TYPE::LEFT, render};
  Paddle right_paddle{PADDLE_TYPE::RIGHT, render};
  app.InsertPaddle(&left_paddle);
  app.InsertPaddle(&right_paddle);

  SDL_SetWindowSize(window, _SCREEN_WIDTH, _SCREEN_HEIGHT);

  SDL_Event event;
  bool quit = false;
  while (!quit) {
    if (SDL_PollEvent(&event)) {
      app.prepareScene();
      PlayerScore PlayerScore{render};
      PlayerScore.Draw();
      switch (event.type) {
        case SDL_QUIT:
          quit = true;
          break;
        default:
          app.handleInput(event);
          break;
      }
      app.presentScene();      
    }
  }

  SDL_Quit();
  return 0;
}

void InitalizeWindowAndRenderer(SDL_Window* &window_ptr, SDL_Renderer* &render_ptr) {
  if (SDL_Init(SDL_INIT_VIDEO) < 0) {
    std::cout << "Failed to initialize the SDL2 library \n";
  }

  window_ptr = SDL_CreateWindow("Pong Game", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
  if (!window_ptr) {
    std::cout<<"Unable to create window \n";
  }

  render_ptr = SDL_CreateRenderer(window_ptr, -1, 0);
  if (!render_ptr) {
    std::cout<< "Unable to create renderer for window \n";
  }
}

void PrepareScene(SDL_Renderer* &render) {
  SDL_SetRenderDrawColor(render, 96, 128, 255, 255);
	SDL_RenderClear(render);
}

void PresentScene(SDL_Renderer* &render) {
  SDL_RenderPresent(render);
}