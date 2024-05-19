cmake_minimum_required(VERSION 3.0)

project(SUPRXManager_stubs)

generate_stub_vitasdk(
        LIBRARY SUPRXManager
        SUPRX ${SFV_FOLDER}/Data/Modules/SUPRXManager.suprx
        MODULE SUPRXManager
        REFPATH ${SFV_FOLDER}/Data/Modules/SUPRXManager_stub_weak.a
        STUBNAME SUPRXManager_stub_weak
)

add_custom_target(SUPRXManager_stubs
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/stubs/libSUPRXManager_stub_weak.a
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/stubs/
        DESTINATION lib
        FILES_MATCHING PATTERN "*.a"
)

