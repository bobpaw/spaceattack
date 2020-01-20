#include "entity.h"

int Entity::RePos (int new_x, int new_y) { // Change x and y values absolutely
  pos_.x = new_x;
  x_ = (float) new_x;
  pos_.y = new_y;
  y_ = (float) new_y;
  return 0;
}

int Entity::Move (float delta_x, float delta_y, bool check) { // Change x and y values relatively
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
