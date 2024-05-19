cmake_minimum_required(VERSION 3.0)

project(pthread_stubs)

generate_stub_vitasdk(
        LIBRARY pthread
        SUPRX ${SFV_FOLDER}/Data/Modules/pthread.suprx
        MODULE PTHREAD_PRX
        REFPATH ${SFV_FOLDER}/Tools/pthread_stub.a
        STUBNAME PTHREAD_PRX_stub
)

add_custom_target(pthread_stubs
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/stubs/libPTHREAD_PRX_stub.a
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/stubs/
        DESTINATION lib
        FILES_MATCHING PATTERN "*.a"
)