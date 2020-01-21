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

#include <SDL.h>
#include <SDL_ttf.h>

#ifndef MOVINGA_TEXT_H_
#define MOVINGA_TEXT_H_

class Text {
 public:
	SDL_Rect pos_;
	std::string text_;
	SDL_Texture * sprite_;
	SDL_Color color_;
	Text () {
		pos_.x = 0;
		pos_.y = 0;
		pos_.w = 0;
		pos_.h = 0;
		text_ = "";
		sprite_ = nullptr;
		color_ = {0, 0, 0, 0};
	}

	Text (std::string text) {
		pos_.x = 0;
		pos_.y = 0;
		pos_.w = 0;
		pos_.h = 0;
		sprite_ = nullptr;
		color_ = {0, 0, 0, 0};
		text_ = text;
	}

	Text (const Text &old) = delete;

	~Text () {
		// SDL_DestroyTexture(sprite_);
	}

	int LoadImage (SDL_Renderer * renderer, TTF_Font * font);
	int Display (SDL_Renderer * renderer);
	int Display (SDL_Renderer * renderer, SDL_Rect destrect);
};

#endif //MOVINGA_TEXT_H_
