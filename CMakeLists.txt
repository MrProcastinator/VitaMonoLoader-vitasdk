cmake_minimum_required(VERSION 3.0)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(VMLBuild)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  if(DEFINED ENV{VITASDK})
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VITASDK}/share/vita.toolchain.cmake" CACHE PATH "toolchain file")
  else()
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
  endif()
endif()

project(VitaMonoLoader)

include("${VITASDK}/share/vita.cmake" REQUIRED)

# Must be provided when running
set(SFV_FOLDER "" CACHE STRING "Unity Support for Vita installation folder")
set(VML_FOLDER "" CACHE STRING "Vita Mono Loader installation folder")
set(MONO_PATH "$ENV{MONO_PATH}" CACHE STRING "Unity Support for Vita Mono library path")
set(MONO_PATH_WIN32 "${MONO_PATH}" CACHE STRING "Unity Support for Vita Mono library path (Windows format)")
set(USE_MONO_COMPILER OFF CACHE BOOL "Use mono compiler to generate AOT files, WSL only")
set(USE_CUSTOM_LIBC ON CACHE BOOL "Use sce_module libraries from Unity Support for Vita")

# Vita library names (for Vita3K)
set(VITA_GL_LIB vitaGL CACHE STRING "Name of OpenGL static library")
set(VITA_VITASHARK_LIB vitashark CACHE STRING "Name of vitashark static library")

if("${SFV_FOLDER}" STREQUAL "")
  message(FATAL_ERROR "You must specify Unity Support for Vita installation folder by setting SFV_FOLDER")
endif()

if("${VML_FOLDER}" STREQUAL "")
  message(FATAL_ERROR "You must specify Vita Mono Loader installation folder by setting VML_FOLDER")
endif()

if("${MONO_PATH}" STREQUAL "")
  message(FATAL_ERROR "You must specify mono-xcompiler Mono folder by setting MONO_PATH")
endif()

if (USE_CUSTOM_LIBC)
  set(SCELIBC_LIBRARY ${CMAKE_BINARY_DIR}/lib/SceLibcMonoBridge/stubs/libSceLibcMonoBridge_stub.a)
  add_compile_definitions(USE_CUSTOM_LIBC)
  add_subdirectory(lib/SceLibcMonoBridge)
else()
  set(SCELIBC_LIBRARY SceLibc_stub)
endif()

include_directories(
  ../headers # Mono libraries includes
  ../headers/mono # Mono libraries includes
  ../headers/VML # VML includes
)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -marm -mtune=cortex-a9 -mfpu=neon -Wno-incompatible-pointer-types -Wno-stringop-overflow -Wl,-q -O3 -Wall")

add_subdirectory(headers)
add_subdirectory(VMLCoreAssemblies)
add_subdirectory(VitaMonoLoader)
add_subdirectory(VMLVita2D)
add_subdirectory(VML_Sample1)
add_subdirectory(VML_Sample2)
