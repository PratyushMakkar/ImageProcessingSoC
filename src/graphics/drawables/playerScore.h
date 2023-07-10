#ifndef __PLAYER_SCORE_H__
#define __PLAYER_SCORE_H__

#include "drawable.h"
#include "paddle.h"

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <utility>


class PlayerScore : public Drawable {
  public:
    PlayerScore(SDL_Renderer* render);
    void UpdateScore(PADDLE_TYPE type);
    virtual void Draw() override;
  private:
    static TTF_Font* surface_font;
    static SDL_Surface* surface;
    std::pair<uint8_t, uint8_t> _score;
};

#endif