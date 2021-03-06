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

#include <iostream> // std::cout
#include <string> // std::string type
// #include <sstream>
#include <vector> // std::vector container type
#include <random>

#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>
#ifndef HAVE_LIBSDL2_MIXER
// Not technically required
#else
#include <SDL2/SDL_mixer.h>
#endif

#include "entity.h"
#include "text.h"
