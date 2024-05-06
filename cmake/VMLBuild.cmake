include(CMakeParseArguments)

function(compile_mono_single_assembly_aot)
    set(oneValueArgs CODE_FILE)
    set(multiValueArgs REFERENCES FLAGS)

    cmake_parse_arguments(MONO "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Convert the list of references to a string with semicolon-separated values
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
        COMMAND mv ${CMAKE_BINARY_DIR}/${MONO_CODE_FILE}.dll.s "${CMAKE_CURRENT_BINARY_DIR}/${MONO_CODE_FILE}.dll.s"
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