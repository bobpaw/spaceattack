#include "text.h"

int Text::LoadImage (SDL_Renderer * renderer, TTF_Font * font) {
  if (sprite_ != nullptr) SDL_DestroyTexture(sprite_);
  SDL_Surface * textsurface = TTF_RenderText_Solid(font, text_.c_str(), color_);
  if (textsurface == NULL) {
    std::cerr << "Unable to render text surface! SDL_ttf error: " << TTF_GetError() << std::endl;
    return -1;
  }
  pos_.w = textsurface->w;
  pos_.h = textsurface->h;
  sprite_ = SDL_CreateTextureFromSurface(renderer, textsurface);
  if (sprite_ == NULL) {
    std::cerr << "Unable to create texture from rendered text! SDL_ttf error: " << TTF_GetError() << std::endl;
    return -1;
  }
  SDL_FreeSurface(textsurface);
  return 0;
}

int Text::Display (SDL_Renderer * renderer) {
  return SDL_RenderCopy(renderer, sprite_, nullptr, &pos_);
}

int Text::Display (SDL_Renderer * renderer, SDL_Rect destrect) {
  return SDL_RenderCopy(renderer, sprite_, NULL, &destrect);
}
