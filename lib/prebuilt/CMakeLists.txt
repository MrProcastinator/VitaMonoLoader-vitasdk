cmake_minimum_required(VERSION 3.0)

project(prebuilt_stubs)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/lib/prebuilt/stubs/libMONO_stub.a
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/stubs/libMONO_stub.a
        ${CMAKE_CURRENT_BINARY_DIR}/stubs/libMONO_stub.a
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/stubs/libMONO_stub.a
    COMMENT "Installing libMONO_stub.a"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/lib/prebuilt/stubs/libPTHREAD_PRX_stub.a
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/stubs/libPTHREAD_PRX_stub.a
        ${CMAKE_CURRENT_BINARY_DIR}/stubs/libPTHREAD_PRX_stub.a
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/stubs/libPTHREAD_PRX_stub.a
    COMMENT "Installing libPTHREAD_PRX_stub.a"
)

add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/lib/prebuilt/stubs/libSUPRXManager_stub_weak.a
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/stubs/libSUPRXManager_stub_weak.a
        ${CMAKE_CURRENT_BINARY_DIR}/stubs/libSUPRXManager_stub_weak.a
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/stubs/libSUPRXManager_stub_weak.a
    COMMENT "Installing libSUPRXManager_stub_weak.a"
)

add_custom_target(mono_stubs
    DEPENDS
        ${CMAKE_BINARY_DIR}/lib/prebuilt/stubs/libMONO_stub.a
        ${CMAKE_BINARY_DIR}/lib/prebuilt/stubs/libPTHREAD_PRX_stub.a
        ${CMAKE_BINARY_DIR}/lib/prebuilt/stubs/libSUPRXManager_stub_weak.a
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/stubs/
        DESTINATION lib
        FILES_MATCHING PATTERN "*.a"
)
