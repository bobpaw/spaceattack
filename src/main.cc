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

#include "main.h"
#include "cmdline.h"

const int kScreenWidth = 640;
const int kScreenHeight = 400;
const int kMaxLives = 10;
const int kMaxBombs = 5; // Max number of fireable bombs

int SDL_main (int argc, char * argv[]) {
  if (SDL_Init(SDL_INIT_EVERYTHING) < 0) {
    std::cerr << "SDL couldn't initialize! SDL_ERROR: " << SDL_GetError() << std::endl;
    return -1;
  }
  if (!(IMG_Init(IMG_INIT_PNG) & IMG_INIT_PNG)) {
    std::cerr << "SDL_Image couldn't init!" << std::endl;
    return -1;
  }
  if (TTF_Init() == -1) {
    std::cerr << "SDL_ttf could not initialize. SDL_ttf error: " << TTF_GetError() << std::endl;
    return -1;
  }
  TTF_Font * font = nullptr;
  font = TTF_OpenFont("data/truetype/freefont/FreeSerif.ttf", 16);
  int kNumStars = 300; // 150 of each type by default
  int y_start = 0;
  int UPKEY;
  int DOWNKEY;
  int LEFTKEY;
  int RIGHTKEY;
  int current_lives = kMaxLives; // Current amount of lives
  gengetopt_args_info args_info;
  if (cmdline_parser(argc, argv, &args_info) != 0) exit(EXIT_FAILURE);
  if (args_info.stars_given) kNumStars = args_info.stars_arg;
  if (args_info.use_arrows_flag) {
    UPKEY = SDL_SCANCODE_UP;
    DOWNKEY = SDL_SCANCODE_DOWN;
    LEFTKEY = SDL_SCANCODE_LEFT;
    RIGHTKEY = SDL_SCANCODE_RIGHT;
  } else {
    UPKEY = SDL_SCANCODE_W;
    DOWNKEY = SDL_SCANCODE_S;
    LEFTKEY = SDL_SCANCODE_A;
    RIGHTKEY = SDL_SCANCODE_D;
  }
  cmdline_parser_free(&args_info);
  std::random_device random;
  SDL_Window * graphics_window = nullptr; // Window object
  SDL_Renderer * graphics_renderer = nullptr; // Surface of screen
  Entity ship("data/ship.png"); // Construct ship entity
  Entity enemy("data/enemy.png"); // Enemy ship
  std::vector<SDL_Rect> bombs(kMaxBombs);
  std::vector<bool> bomb_exist(kMaxBombs);
  int bombAmmo = kMaxBombs;
  int bombLag = 0;
  Entity bombsprite("data/bomb.png");
  std::vector<SDL_Rect> star1s(kNumStars/2); // Create vector of star1 coordinates
  std::vector<SDL_Rect> star2s(kNumStars/2); // Create vector of star2 coordinates
  Entity star1sprite("data/Star1.png"); // Construct object for star1 sprite
  Entity star2sprite("data/Star2.png"); // Construct object for star2 sprite
  bool window_quit = false;
  SDL_Event event;
  float velocity = 2; // Set ship velocity
  const uint8_t * key_state = SDL_GetKeyboardState(nullptr); // Get address of keystate array and assign it to keyState pointer
  graphics_window = SDL_CreateWindow("SpaceAttack!", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, kScreenWidth, kScreenHeight, SDL_WINDOW_SHOWN);
  // SDL_CreateWindow(name, windowx, windowy, width, height, options
  if (graphics_window == nullptr) {
    std::cerr << "SDL couldn't initialize window! SDL_Error: " << SDL_GetError() << std::endl;
    return -1;
  }
  graphics_renderer = SDL_CreateRenderer(graphics_window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC); // Use hardware acceleration and vsync
  std::vector<Text> bombs_text(kMaxBombs+1); // kMaxBombs + 1 because I need text for when it's 0
  for (int i = 0; i < kMaxBombs+1; i++) {
    bombs_text[i].color_ = {255, 255, 255, 255}; // White (0xffffff) at max alpha
    bombs_text[i].text_ = "Bombs: " + std::to_string(i); // ex: 'Bombs: 3'
    bombs_text[i].LoadImage(graphics_renderer, font); // Create text from font and renderer
  }
  std::vector<Text> lives_text(kMaxLives+1);
  for (int i = 0; i < kMaxLives+1; i++) {
    lives_text[i].color_ = {255, 255, 255, 255};
    lives_text[i].text_ = "Lives: " + std::to_string(i);
    lives_text[i].LoadImage(graphics_renderer, font);
    lives_text[i].pos_.x = kScreenWidth - lives_text[i].pos_.w - 5;
  }
  y_start = bombs_text[1].pos_.h;
  SDL_SetRenderDrawColor(graphics_renderer, 0x00, 0x00, 0x00, 0xff);
  ship.LoadImage(graphics_renderer, y_start); // Load ship image into memory
  enemy.LoadImage(graphics_renderer);
  bombsprite.LoadImage(graphics_renderer);
  star1sprite.LoadImage(graphics_renderer); // Load star1 image into memory
  star2sprite.LoadImage(graphics_renderer); // Load star2 image into memory
  for (int i = 0; i < kNumStars/2; i++) { // Loop for each star (NUM_OF_STARS is both types)
    star1s[i] = star1sprite.pos_; // Set width and height for stars of type 1
    star2s[i] = star2sprite.pos_; // Set width and height for stars of type 2
    star1s[i].x = random() % kScreenWidth; // Set random x value of range [0, SCREEN_WIDTH)
    star1s[i].y = (random() % (kScreenHeight - y_start)) + y_start; // Set random y value of range [0, SCREEN_HEIGHT)
    star2s[i].x = random() % kScreenWidth; // Set random x value of range [0, SCREEN_WIDTH)
    star2s[i].y = (random() % (kScreenHeight - y_start)) + y_start; // Set random y value of range [0, SCREEN_HEIGHT)
  }
  for (int i = 0; i < 5; i++) {
    bombs[i] = bombsprite.pos_;
  }
  enemy.RePos(320, 200);
  while (window_quit == false) {
    while (SDL_PollEvent( &event ) != 0) { // SDL_PollEvent automatically updates key_state array
      if (event.type == SDL_QUIT) {
	// Check if X button (in top right) has been pressed
	window_quit = true;
      }
    }
    if (key_state[UPKEY] && !key_state[DOWNKEY]) {
      // Get state of Up arrow key
      ship.Move(0, -velocity);
    } else if (!key_state[UPKEY] && key_state[DOWNKEY]) {
      ship.Move(0, velocity);
    } else if (key_state[UPKEY] && key_state[DOWNKEY]) {

    }
    if (key_state[LEFTKEY] && key_state[RIGHTKEY]) {

    } else if (key_state[LEFTKEY] && !key_state[RIGHTKEY]) {
      ship.Move(-velocity, 0);
    } else if (!key_state[LEFTKEY] && key_state[RIGHTKEY]) {
      ship.Move(velocity, 0);
    }
    if (key_state[SDL_SCANCODE_SPACE] && bombLag == 0) {
      for (int i = 0; i < bombs.size(); i++) {
	if (!bomb_exist[i]) {
	  bombAmmo--;
	  bomb_exist[i] = true;
	  bombs[i].y = ship.pos_.y - 18;
	  bombs[i].x = ship.pos_.x + 3;
	  bombLag = 12;
	  break;
	}
      }
    }
    SDL_RenderClear(graphics_renderer); // Cover screen in a black rectangle, effectively clearing the screen
    bombs_text[bombAmmo].Display(graphics_renderer);
    lives_text[current_lives].Display(graphics_renderer);
    for (int i = 0; i < kNumStars/2; i++) {
      star1s[i].y++; // Increase star type 1 y positions
      star2s[i].y++; // Increase star type 2 y positions
      if (star1s[i].y >= kScreenHeight) {
	// Check if stars of type 1 have gone outside the screen
	star1s[i].y = y_start; // Reset y coordinates if so
	star1s[i].x = random() % kScreenWidth;
      }
      if (star2s[i].y >= kScreenHeight) {
	// Check if stars of type 2 have gone outside the screen
	star2s[i].y = y_start; // Reset y coordinates if so
	star2s[i].x = random() % kScreenWidth;
      }
      star1sprite.Display(graphics_renderer, star1s[i]); // Display stars of type 1 using overload allowing for coordinate input
      star2sprite.Display(graphics_renderer, star2s[i]); // Display stars of type 2
    }
    for (int i = 0; i < bombs.size(); i++) {
      if (bomb_exist[i]) {
	bombs[i].y-= 4;
	if ((bombs[i].y) <= y_start) {
	  bombs[i].y = 0;
	  bombs[i].x = 0;
	  bomb_exist[i] = false;
	  bombAmmo++;
	} else {
	  bombsprite.Display(graphics_renderer, bombs[i]);
	}
      }
    }
    if (bombLag > 0) bombLag--;
    enemy.Display(graphics_renderer);
    ship.Display(graphics_renderer); // Call entity::display() function for ship
    SDL_RenderPresent(graphics_renderer); // Update screen based on changes
    // Using VSYNC SDL_Delay(20); // Wait 20 milliseconds, should blip 50 fps
  }
  SDL_RenderClear(graphics_renderer);
  SDL_DestroyWindow(graphics_window); // Destroy window; should free surface associated with screen.
  SDL_DestroyRenderer(graphics_renderer);
  graphics_window = nullptr;
  graphics_renderer = nullptr;
  TTF_Quit(); // Quit and unload SDL-ttf module
  IMG_Quit(); // Quit and unload SDL-image module
  SDL_Quit(); // Quit and unload SDL module
  return 0;
}
