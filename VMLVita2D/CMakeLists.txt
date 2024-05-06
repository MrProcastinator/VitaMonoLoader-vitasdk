# Enable asm for AOT library support
enable_language(ASM)

## Define project parameters here
# Name of the project
project(VMLVita2D)
# This line adds Vita helper macros, must go after project definition in order
# to build Vita specific artifacts (self/vpk).
include("${VITASDK}/share/vita.cmake" REQUIRED)

# Add any additional include paths here
include_directories(
  ../headers
  ../headers/mono # Mono libraries includes
  ../headers/VML # VML includes
)

# Compile the DLL using the supplied Unity mono
if(USE_MONO_COMPILER)
  compile_mono_single_assembly_aot(CODE_FILE Vita2D)
endif()

## Build and link
# Add all the files needed to compile here
add_library(${PROJECT_NAME} STATIC
  main.c
  Vita2D.dll.s
)

add_dependencies(${PROJECT_NAME} headers)