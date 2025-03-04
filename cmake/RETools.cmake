include(CMakeParseArguments)

set(RE_TOOL_VITA_UNMAKE_FSELF "vita-unmake-fself.exe" CACHE STRING "Path to vita-unmake-fself tool")
set(RE_TOOL_NIDS_EXTRACT "nids-extract.exe" CACHE STRING "Path to nids-extract tool")
set(RE_TOOL_VITA_LIBS_GEN "vita-libs-gen" CACHE STRING "Path to vita-libs-gen tool")

function(generate_stub_vitasdk)
    set(oneValueArgs LIBRARY SUPRX MODULE REFPATH STUBNAME)

    cmake_parse_arguments(RE_TOOLS "" "${oneValueArgs}" "" ${ARGN})

    get_filename_component(RE_TOOLS_SUPRX_FILENAME ${RE_TOOLS_SUPRX} NAME)
    get_filename_component(RE_TOOLS_REFNAME ${RE_TOOLS_REFPATH} NAME)

    # HACK: nids-extract.exe always returns 1, so we need to wrap it and execute it in python script
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${RE_TOOLS_LIBRARY}.yaml
        COMMAND ${CMAKE_COMMAND} -E copy
        ${RE_TOOLS_SUPRX}
        ${CMAKE_CURRENT_BINARY_DIR}/${RE_TOOLS_SUPRX_FILENAME}
        COMMAND ${RE_TOOL_VITA_UNMAKE_FSELF} ${RE_TOOLS_SUPRX_FILENAME}
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${CMAKE_SOURCE_DIR}/tools/nids-extract-wrapper.py ${RE_TOOL_NIDS_EXTRACT} ${RE_TOOLS_SUPRX_FILENAME}.elf 3.60 > ${RE_TOOLS_LIBRARY}.yaml
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Building initial stubs for ${RE_TOOLS_LIBRARY}"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${RE_TOOLS_REFNAME}
        COMMAND ${CMAKE_COMMAND} -E copy
        ${RE_TOOLS_REFPATH}
        ${CMAKE_CURRENT_BINARY_DIR}/${RE_TOOLS_REFNAME}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${RE_TOOLS_LIBRARY}.yaml
        COMMENT "Installing ${RE_TOOLS_REFNAME}"
    )
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/stubs/lib${RE_TOOLS_STUBNAME}.a
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${CMAKE_SOURCE_DIR}/tools ${CMAKE_SOURCE_DIR}/tools/replace-nid-symbols-sce.py ${RE_TOOLS_REFNAME} ${RE_TOOLS_LIBRARY}.yaml ${RE_TOOLS_MODULE}
        COMMAND ${CMAKE_COMMAND} -E env PYTHONPATH=${CMAKE_SOURCE_DIR}/tools ${CMAKE_SOURCE_DIR}/tools/clean-nids.py ${RE_TOOLS_LIBRARY}.yaml
        COMMAND vita-libs-gen ${RE_TOOLS_LIBRARY}.yaml stubs
        COMMAND make -C stubs
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${RE_TOOLS_REFNAME}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Generating stubs lib${RE_TOOLS_STUBNAME}.a"
    )
endfunction()