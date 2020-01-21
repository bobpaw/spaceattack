/*
	SpaceAttack! is a small 2D shooter game
	Copyright (C) 2020 Aiden Woodruff

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
#include <string> // std::string type

#include <SDL.h>
#include <SDL_image.h>

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
	int Move (float delta_x, float delta_y, bool check = true); // Change x and y variables relatively
	int Display (SDL_Renderer * &renderer); // Display image using included SDL_Rect
	int Display (SDL_Renderer * &renderer, SDL_Rect destrect); // Overload for specifying other coordinates
	int LoadImage (SDL_Renderer * &renderer, int y_begin = 0); // Load image from file and optimize based on screen pixel format

	Entity (std::string file) :
	x_(0.0), y_(0.0), y_start(0),
			spritefile_(file), spritehandle_(nullptr), shadow_screenheight_{ 0 }, shadow_screenwidth_{ 0 } {
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
		return *this;
	}
};

#endif // MOVINGA_ENTITY_H_
