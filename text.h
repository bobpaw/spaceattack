/*
  SpaceAttack! is a small 2D shooter game
  Copyright (C) 2017  Aiden Woodruff

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.

  If you have any questions, please email me at <aidenpw@hotmail.com>.
*/

#include "config.h"

#include <iostream> // std::cerr
#include <string> // std::string

#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

#ifndef MOVINGA_TEXT_H_
#define MOVINGA_TEXT_H_

class Text {
 public:
  SDL_Rect pos_;
  std::string font_file_;
  std::string text_;
  SDL_Texture * sprite_;
  SDL_Color color_;
  Text () {
    pos_.x = 0;
    pos_.y = 0;
    pos_.w = 0;
    pos_.h = 0;
    font_file_ = "";
    text_ = "";
    sprite_ = nullptr;
    color_ = {0, 0, 0, 0};
  }
  
  Text (std::string file) : Text() {
    font_file_ = file;
  }

  Text (std::string file, std::string text) : Text() {
    font_file_ = file;
    text_ = text;
  }

  Text (const Text &old) = delete;

  ~Text () {
    SDL_DestroyTexture(sprite_);
  }
  int LoadImage (SDL_Renderer * &renderer, TTF_Font * &font);
  int Display (SDL_Renderer * &renderer);
  int Display (SDL_Renderer * &renderer, SDL_Rect &destrect);
};

int Text::LoadImage (SDL_Renderer * &renderer, TTF_Font * &font) {
  SDL_DestroyTexture(sprite_);
  SDL_Surface * textsurface = TTF_RenderText_Solid(font, text_.c_str(), color_);
  if (textsurface == NULL) {
    std::cerr << "Unable to render text surface! SDL_ttf error: " << TTF_GetError() << std::endl;
    return -1;
  }
  sprite_ = SDL_CreateTextureFromSurface(renderer, textsurface);
  if (sprite_ == NULL) {
    std::cerr << "Unable to create texture from rendered text! SDL_ttf error: " << TTF_GetError() << std::endl;
    return -1;
  }
  pos_.w = textsurface->w;
  pos_.h = textsurface->h;
  SDL_FreeSurface(textsurface);
  return 0;
}

inline int Text::Display (SDL_Renderer * &renderer) {
  SDL_RenderCopy(renderer, sprite_, NULL, &pos_);
}

inline int Text::Display (SDL_Renderer * &renderer, SDL_Rect &destrect) {
  SDL_RenderCopy(renderer, sprite_, NULL, &destrect);
}

#endif //MOVINGA_TEXT_
