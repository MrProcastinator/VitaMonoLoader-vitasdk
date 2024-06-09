include(CMakeParseArguments)

# Must be provided when running
set(SFV_FOLDER "" CACHE STRING "Unity Support for Vita installation folder")
set(MONO_PATH "$ENV{MONO_PATH}" CACHE STRING "Unity Support for Vita Mono library path")

if("${SFV_FOLDER}" STREQUAL "")
  message(FATAL_ERROR "You must specify Unity Support for Vita installation folder by setting SFV_FOLDER")
endif()

if("${MONO_PATH}" STREQUAL "")
  message(FATAL_ERROR "You must specify mono-xcompiler Mono folder by setting MONO_PATH")
endif()

# Mono variables
set(MONO_INCLUDE_VML_PATH "include/VML" CACHE STRING "Mono VML initializers include path")
set(MONO_LIB_DLL_PATH "lib/mono" CACHE STRING "Mono VML DLL path")
set(MONO_LIB_VML_PATH "lib" CACHE STRING "Mono VML static library path")

# VMLBuild script Version
set(VMLBUILD_VERSION_MAX 0)
set(VMLBUILD_VERSION_MIN 1)
set(VMLBUILD_VERSION_PATCH 0)

message("Using VMLBuild version ${VMLBUILD_VERSION_MAX}.${VMLBUILD_VERSION_MIN}.${VMLBUILD_VERSION_PATCH}")
message("With Unity Support for Vita located at: '${SFV_FOLDER}'")
message("With Mono 2.0 lib folder (WSL/Win32 format) located at: '${MONO_PATH}'")
message("With the following mono paths:")
message("- VML Header installation path: ${MONO_INCLUDE_VML_PATH}")
message("- Mono Library installation path: ${MONO_LIB_DLL_PATH}")
message("- Static Library installation path: ${MONO_LIB_VML_PATH}")

function(compile_mono_assembly_aot)
    set(oneValueArgs ASSEMBLY CONFIG)
    set(multiValueArgs SOURCES REFERENCES FLAGS RESOURCES DEFINES)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(SOURCE_ARGS "")
    if(MONO_SOURCES)
      foreach(SRC ${MONO_SOURCES})
        list(APPEND SOURCE_ARGS ${SRC})
      endforeach()
    endif()

    set(REFERENCE_ARGS "")
    if(MONO_REFERENCES)
      foreach(REF ${MONO_REFERENCES})
        list(APPEND REFERENCE_ARGS -r:${REF})
      endforeach()
    endif()

    set(FLAG_ARGS "")
    if(MONO_FLAGS)
      foreach(FLAG ${MONO_FLAGS})
        list(APPEND FLAGS_ARGS -${FLAG})
      endforeach()
    endif()

    set(RESOURCE_ARGS "")
    if(MONO_RESOURCES)
      foreach(RES ${MONO_RESOURCES})
        list(APPEND RESOURCE_ARGS -resource:${RES})
      endforeach()
    endif()

    set(DEFINE_ARGS "")
    if(MONO_DEFINES)
      foreach(DEF ${MONO_DEFINES})
        list(APPEND DEFINE_ARGS -define:${DEF})
      endforeach()
    endif()

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.dll
        COMMAND export "MONO_PATH='${MCS_PATH}'" && WSLENV=MONO_PATH/p mcs -sdk:2 -target:library -out:${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.dll ${MONO_SOURCES} -lib:${CMAKE_BINARY_DIR} ${FLAGS_ARGS} ${REFERENCE_ARGS} ${RESOURCE_ARGS} ${DEFINE_ARGS}
        DEPENDS ${MONO_SOURCES}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Compiling assembly ${MONO_ASSEMBLY}.dll"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${MONO_ASSEMBLY}.dll.s
        COMMAND export "MONO_PATH=${MONO_PATH}" && "WSLENV=MONO_PATH/p" "${SFV_FOLDER}/Tools/mono-xcompiler.exe" --aot=full,asmonly,nodebug,static ${MONO_ASSEMBLY}.dll
        COMMAND mv ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.dll.s "${CMAKE_CURRENT_BINARY_DIR}/${MONO_ASSEMBLY}.dll.s"
        DEPENDS ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.dll
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Generating AOT file for ${MONO_ASSEMBLY}.dll"
    )

    if(MONO_CONFIG)
        add_custom_command(
            OUTPUT ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.dll.config
            COMMAND ${CMAKE_COMMAND} -E copy
                ${MONO_CONFIG}
                ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.dll.config
            DEPENDS ${MONO_CONFIG}
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
            COMMENT "Generating config file for ${MONO_ASSEMBLY}.dll"
        )
    endif()
endfunction()

function(compile_mono_dll_aot)
    set(oneValueArgs DLL_FILE)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "" ${ARGN})

    get_filename_component(DLL_BASENAME "${MONO_DLL_FILE}" NAME)

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${DLL_BASENAME}.s
        COMMAND export "MONO_PATH=${MONO_PATH}" && "WSLENV=MONO_PATH/p" "${SFV_FOLDER}/Tools/mono-xcompiler.exe" --aot=full,asmonly,nodebug,static "${MONO_DLL_FILE}"
        DEPENDS "${MONO_DLL_FILE}"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating AOT file for ${DLL_BASENAME}"
    )
endfunction()

function(compile_mono_external_dll_aot)
    set(oneValueArgs ASSEMBLY)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "" ${ARGN})

    add_custom_command(
        OUTPUT "${SFV_FOLDER}/Tools/MonoPSP2/${MONO_ASSEMBLY}.s"
        COMMAND export "MONO_PATH=${MONO_PATH}" && "WSLENV=MONO_PATH/p" "${SFV_FOLDER}/Tools/mono-xcompiler.exe" --aot=full,asmonly,nodebug,static "'${MONO_PATH_WIN32}\\${MONO_ASSEMBLY}'"
        DEPENDS "${SFV_FOLDER}/Tools/MonoPSP2/${MONO_ASSEMBLY}"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating AOT file for ${MONO_ASSEMBLY}"
    )

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${MONO_ASSEMBLY}.s
        COMMAND ${CMAKE_COMMAND} -E copy
            ${SFV_FOLDER}/Tools/MonoPSP2/${MONO_ASSEMBLY}.s
            ${CMAKE_CURRENT_BINARY_DIR}/${MONO_ASSEMBLY}.s
        DEPENDS "${SFV_FOLDER}/Tools/MonoPSP2/${MONO_ASSEMBLY}.s"
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Copying AOT file for ${MONO_ASSEMBLY}"
    )
endfunction()

function(compile_mono_single_assembly_aot)
    set(oneValueArgs ASSEMBLY CODE_FILE)
    
    cmake_parse_arguments(MONO "" "${oneValueArgs}" "" ${ARGN})

    if(MONO_ASSEMBLY)
    else()
        set(MONO_ASSEMBLY ${MONO_CODE_FILE})
    endif()

    compile_mono_assembly_aot(
        ASSEMBLY ${MONO_ASSEMBLY}
        SOURCES ${MONO_CODE_FILE}.cs
        ${MONO_UNPARSED_ARGUMENTS}
    )
endfunction()

function(compile_mono_external_import)
    set(oneValueArgs ASSEMBLY TARGET LIBPATH)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "" ${ARGN})

    if(MONO_LIBPATH)
    else()
      set(MONO_LIBPATH "${CMAKE_INSTALL_PREFIX}/${MONO_LIB_DLL_PATH}")
    endif()

    set(ASSEMBLY_PATH "${MONO_LIBPATH}/${MONO_ASSEMBLY}")

    add_custom_command(
        TARGET ${MONO_TARGET}
        COMMAND ${CMAKE_COMMAND} -E copy
            "${ASSEMBLY_PATH}"
            ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}
        DEPENDS "${ASSEMBLY_PATH}"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Importing assembly dependency ${MONO_ASSEMBLY}"
    )
endfunction()