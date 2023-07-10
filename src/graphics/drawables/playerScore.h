#ifndef __PLAYER_SCORE_H__
#define __PLAYER_SCORE_H__

#include "drawable.h"
#include "paddle.h"

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <utility>

#define FONT_PATH "drawables/Arial.ttf"

class PlayerScore : public Drawable {
  public:
    PlayerScore(SDL_Renderer* render);
    void UpdateScore(PADDLE_TYPE type);
    virtual void Draw() override;
  private:
    static TTF_Font* surface_font;
    std::pair<uint8_t, uint8_t> _score;
};

#endif