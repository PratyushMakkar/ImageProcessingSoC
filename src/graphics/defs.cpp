#include "defs.h"

SDLApp::SDLApp(SDL_Window* &window, SDL_Renderer* &render) {
  if (SDL_Init(SDL_INIT_VIDEO) < 0) {
    std::cout << "Failed to initialize the SDL2 library \n";
  }

  if (TTF_Init()) {
    std::cout << "Failed to initalize TTF font library" "\n";
  }
  
  window = SDL_CreateWindow("Pong Game", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, 640, 480, 0);
  if (!window) {
    std::cout<<"Unable to create window \n";
  }

  render = SDL_CreateRenderer(window, -1, 0);
  if (!render) {
    std::cout<< "Unable to create renderer for window \n";
  }
  this->render_ptr = &render;
  this->window_ptr = &window;
}

SDLApp::~SDLApp() {
  
}

void SDLApp::prepareScene() {
  SDL_Renderer* render_ptr = *(this->render_ptr);
  SDL_SetRenderDrawColor(render_ptr, 0x0, 0x0, 0x0, 0xFF);
	SDL_RenderClear(render_ptr);
}

void SDLApp::presentScene() {
  SDL_RenderPresent(*(this->render_ptr));
}

void SDLApp::InsertPaddle(Paddle* paddle) {
  const uint8_t index = INDEX(paddle->type);
  this->drawables.insert(this->drawables.begin() + index, paddle);
}

Paddle* SDLApp::GetPaddle(PADDLE_TYPE m_type) {
  const uint8_t index = INDEX(m_type);
  std::vector<Drawable*> drawables = this->drawables;
  return dynamic_cast<Paddle*>(drawables.at(index));
}

void SDLApp::handleInput(SDL_Event &e) {
  for (auto drawable: this->drawables) {
    drawable->Draw();
  }
}