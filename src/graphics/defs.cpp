#include "defs.h"

SDLApp::SDLApp(SDL_Surface *window_surface_ptr, SDL_Window* window_ptr) {
  this->window_ptr = window_ptr;
  this->window_surface_ptr = window_surface_ptr;
}

SDLApp::~SDLApp() {
  
}


void SDLApp::prepareScene() {

}

void SDLApp::presentScene() {

}