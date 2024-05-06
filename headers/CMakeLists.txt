cmake_minimum_required(VERSION 3.0)
project(VMLMonoHeaders)

set(MONO_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/mono)
set(VML_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/VML)

add_custom_target(headers)

add_custom_command(
  TARGET headers
  COMMAND ${CMAKE_COMMAND} -E copy_directory
          ${CMAKE_CURRENT_SOURCE_DIR}/mono
          $ENV{VITASDK}/arm-vita-eabi/include/mono
)

add_custom_command(
  TARGET headers
  COMMAND ${CMAKE_COMMAND} -E copy_directory
          ${CMAKE_CURRENT_SOURCE_DIR}/VML
          $ENV{VITASDK}/arm-vita-eabi/include/VML
)
