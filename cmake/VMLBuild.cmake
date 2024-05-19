include(CMakeParseArguments)

function(compile_mono_single_assembly_aot)
    set(oneValueArgs CODE_FILE)
    set(multiValueArgs REFERENCES FLAGS)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

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

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/${MONO_CODE_FILE}.dll
        COMMAND export "MONO_PATH='${MCS_PATH}'" && WSLENV=MONO_PATH/p mcs -sdk:2 -target:library -out:${CMAKE_BINARY_DIR}/${MONO_CODE_FILE}.dll ${MONO_CODE_FILE}.cs -lib:${CMAKE_BINARY_DIR} ${FLAGS_ARGS} ${REFERENCE_ARGS}
        DEPENDS ${MONO_CODE_FILE}.cs
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Compiling ${MONO_CODE_FILE}.cs to ${MONO_CODE_FILE}.dll"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${MONO_CODE_FILE}.dll.s
        COMMAND export "MONO_PATH=${MONO_PATH}" && "WSLENV=MONO_PATH/p" "${SFV_FOLDER}/Tools/mono-xcompiler.exe" --aot=full,asmonly,nodebug,static ${MONO_CODE_FILE}.dll
        COMMAND ${CMAKE_COMMAND} -E rename
            ${CMAKE_BINARY_DIR}/${MONO_CODE_FILE}.dll.s
            "${CMAKE_CURRENT_BINARY_DIR}/${MONO_CODE_FILE}.dll.s"
        DEPENDS ${CMAKE_BINARY_DIR}/${MONO_CODE_FILE}.dll
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Generating AOT file for ${MONO_CODE_FILE}.dll"
    )
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
    set(multiValueArgs REFERENCES)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    set(MONO_WIN32_PATH ${CMAKE_BINARY_DIR})

    set(REFERENCE_ARGS "")
    if(MONO_REFERENCES)
      foreach(REF ${MONO_REFERENCES})
        list(APPEND REFERENCE_ARGS "${CMAKE_BINARY_DIR}/${REF}")
      endforeach()
    endif()

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}
        COMMAND ${CMAKE_COMMAND} -E copy
            "${SFV_FOLDER}/Tools/MonoPSP2/${MONO_ASSEMBLY}"
            ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}
        DEPENDS "${SFV_FOLDER}/Tools/MonoPSP2/${MONO_ASSEMBLY}"
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Installing external assembly ${MONO_ASSEMBLY}"
    )

    add_custom_command(
        OUTPUT ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.s
        COMMAND export "MONO_PATH=${MONO_WIN32_PATH}" && "WSLENV=MONO_PATH/p" "${SFV_FOLDER}/Tools/mono-xcompiler.exe" --aot=full,asmonly,nodebug,static ${MONO_ASSEMBLY}
        DEPENDS ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY} ${REFERENCE_ARGS}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
        COMMENT "Generating AOT file for ${MONO_ASSEMBLY}"
    )

    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${MONO_ASSEMBLY}.s
        COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.s
            ${CMAKE_CURRENT_BINARY_DIR}/${MONO_ASSEMBLY}.s
        DEPENDS ${CMAKE_BINARY_DIR}/${MONO_ASSEMBLY}.s
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Copying AOT file for ${MONO_ASSEMBLY}"
    )
endfunction()