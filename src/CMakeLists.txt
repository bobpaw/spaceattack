set(SDL_NS "$<IF:$<BOOL:${PKG_CONFIG_FOUND}>,PkgConfig,SDL2>")
add_library(text OBJECT text.cc text.h)
target_link_libraries(text "${SDL_NS}::SDL2" "${SDL_NS}::SDL2_ttf")
# target_compile_features(text PUBLIC ...)

add_library(entity OBJECT entity.cc entity.h)
target_link_libraries(entity "${SDL_NS}::SDL2" "${SDL_NS}::SDL2_image")
# target_compile_features(entity PUBLIC ...)

if (HAVE_GGO)
	add_custom_command(OUTPUT cmdline.c cmdline.h COMMAND "gengetopt" ARGS "--input" "args.ggo" MAIN_DEPENDENCY args.ggo)
endif()

add_executable(movinga main.cc main.h text entity)
target_link_libraries(movinga "${SDL_NS}::SDL2" "${SDL_NS}::SDL2_image" "${SDL_NS}::SDL2_ttf")
## target_compile_features(movinga PRIVATE ...)

add_custom_command(TARGET movinga PRE_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_SOURCE_DIR}/src/data/ $<TARGET_FILE_DIR:movinga>/data)