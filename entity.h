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

#include <iostream> // std::cerr
#include <string> // std::string type

#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_mixer.h>

#include "config.h"

#ifndef MOVINGA_ENTITY_H_
#define MOVINGA_ENTITY_H_

class Entity {
 private:
  float x_; // Because SDL_Rect only has int x (in case velocity is decimal)
  float y_; // Because SDL_Rect only has int y (in case velocity is decimal)
  int y_start; // Where y starts. This defaults to 0
  int shadow_screenwidth_;
  int shadow_screenheight_; // Shadow screen height and width are aquired during image load and assumed for the rest of the runtime

 public:
  SDL_Rect pos_; // Coordinate rectangle
  std::string spritefile_; // File containing entity type
  SDL_Texture * spritehandle_; // Surface for sprite access


  int RePos (int new_x, int new_y); // Change x and y variables (in SDL_Rect and internal) absolutely
  int Move (float delta_x, float delta_y, bool check); // Change x and y variables relatively
  int Display (SDL_Renderer * &renderer); // Display image using included SDL_Rect
  int Display (SDL_Renderer * &renderer, SDL_Rect destrect); // Overload for specifying other coordinates
  int LoadImage (SDL_Renderer * &renderer, int y_begin = 0); // Load image from file and optimize based on screen pixel format

  Entity (std::string file) :
  x_(0.0), y_(0.0), y_start(0),
  spritefile_(file), spritehandle_(nullptr) {
    pos_.x = 0; pos_.y = 0; pos_.w = 0; pos_.h = 0;
  }

  Entity () : Entity("") {}

  ~Entity () {
    // SDL_DestroyTexture(spritehandle_); Not required as SDL_DestroyRenderer frees it
  }

  Entity (const Entity &old) = delete;

  Entity& operator= (const Entity & old) {
    // Copy assignment
    shadow_screenwidth_ = old.shadow_screenwidth_;
    shadow_screenheight_ = old.shadow_screenheight_;
    pos_ = old.pos_;
    x_ = old.x_;
    y_ = old.y_;
    y_start = old.y_start;
    spritefile_ = old.spritefile_;
    SDL_DestroyTexture(spritehandle_);
    spritehandle_ = old.spritehandle_;
  }
};

int Entity::RePos (int new_x, int new_y) { // Change x and y values absolutely
  pos_.x = new_x;
  x_ = (float) new_x;
  pos_.y = new_y;
  y_ = (float) new_y;
  return 0;
}

int Entity::Move (float delta_x, float delta_y, bool check = true) { // Change x and y values relatively
  if (SDL_WasInit(SDL_INIT_VIDEO) != 0 && (
		pos_.x + delta_x + pos_.w <= shadow_screenwidth_ &&
		pos_.x + delta_x >= 0 &&
		pos_.y + delta_y + pos_.h <= shadow_screenheight_ &&
		pos_.y + delta_y >= y_start) || !check) {
      x_ += delta_x;
      y_ += delta_y;
      pos_.x = static_cast<int>(x_);
      pos_.y = static_cast<int>(y_);
  } else
    return -1;
  return 0;
}

int Entity::Display (SDL_Renderer * &renderer) { // Blit surface to screen (function is short enough to be inline)
  return SDL_RenderCopy(renderer, spritehandle_, NULL, &pos_);
}

int Entity::Display (SDL_Renderer * &renderer, SDL_Rect destrect) { // Blit surface to screen (function is short enough to be inline) using external coordinates
  return SDL_RenderCopy(renderer, spritehandle_, NULL, &destrect);
}

int Entity::LoadImage (SDL_Renderer * &renderer, int y_begin) {
  y_start = y_begin;
  pos_.y = y_start;
  y_ = (float) y_start;
  if (spritehandle_ != nullptr) SDL_DestroyTexture(spritehandle_);
  SDL_GetRendererOutputSize(renderer, &shadow_screenwidth_, &shadow_screenheight_);
  if (spritefile_ == "") {
    return -1;
  }
  SDL_Surface * temp_surface = nullptr; // Temporary load surface
  temp_surface = IMG_Load(spritefile_.c_str()); // Load image into memory using SDL_image
  if (temp_surface == nullptr) {
    std::cerr << "Unable to load image " << spritefile_ << ". SDL_image Error: " << IMG_GetError() << std::endl;
    return -1;
  }
  pos_.w = temp_surface->w;
  pos_.h = temp_surface->h;
  spritehandle_ = SDL_CreateTextureFromSurface(renderer, temp_surface); // Optimize image
  if (spritehandle_ == nullptr) { // Check if optimization succeeded
    std::cerr << "Unable to create texture " << spritefile_ << ". SDL Error: " << SDL_GetError() << std::endl;
    return -1;
  }
  SDL_FreeSurface(temp_surface); // Free unoptimized surface
  return 0;
}

#endif // MOVINGA_ENTITY_H_
