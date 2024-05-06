# Enable asm for AOT library support
enable_language(ASM)

project(VitaMonoLoader)

include_directories(
  ../headers
  ../headers/mono # Mono libraries includes
  ../headers/VML # VML includes
)

add_library(${PROJECT_NAME} STATIC
  main.c
)

add_dependencies(${PROJECT_NAME} headers)

install(
  TARGETS ${PROJECT_NAME}
  DESTINATION lib
)