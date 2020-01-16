add_library(text OBJECT text.cc text.h)
target_link_libraries(text SDL2::SDL2 SDL2::SDL2_image)
# target_compile_features(text PUBLIC ...)

add_library(entity OBJECT entity.cc entity.h)
# target_compile_features(entity PUBLIC ...)

if (HAVE_GGO)
	add_custom_command(OUTPUT cmdline.c cmdline.h COMMAND "gengetopt" ARGS "--input" "args.ggo" MAIN_DEPENDENCY args.ggo)
endif()

add_executable(movinga main.cc main.h cmdline.c cmdline.h text entity)
target_link_libraries(movinga SDL2::SDL2main SDL2::SDL2_image SDL2::SDL2_ttf)
## target_compile_features(movinga PRIVATE ...)