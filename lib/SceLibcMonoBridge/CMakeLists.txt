cmake_minimum_required(VERSION 3.0)

project(SceLibcMonoBridge)
include("${VITASDK}/share/vita.cmake" REQUIRED)

add_custom_target(SceLibcMonoBridge ALL
        COMMAND vita-libs-gen ${CMAKE_CURRENT_SOURCE_DIR}/libc.yaml ${CMAKE_CURRENT_BINARY_DIR}/stubs
        COMMAND make -C ${CMAKE_CURRENT_BINARY_DIR}/stubs
        COMMENT "Building stubs for SceLibcMonoBridge"
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/stubs/
        DESTINATION lib
        FILES_MATCHING PATTERN "*.a"
)