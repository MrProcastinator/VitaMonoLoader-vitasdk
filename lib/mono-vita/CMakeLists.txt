cmake_minimum_required(VERSION 3.0)

project(mono-vita_stubs)

generate_stub_vitasdk(
        LIBRARY mono-vita
        MODULE MONO
        SUPRX ${SFV_FOLDER}/Data/Modules/mono-vita.suprx
        REFPATH ${SFV_FOLDER}/Data/Modules/mono-vita_stub.a
        STUBNAME MONO_stub
)

add_custom_target(mono-vita_stubs
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/stubs/libMONO_stub.a
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/stubs/
        DESTINATION lib
        FILES_MATCHING PATTERN "*.a"
)
