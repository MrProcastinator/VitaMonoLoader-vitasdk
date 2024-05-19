# Enable asm for AOT library support
enable_language(ASM)

project(VMLCoreAssemblies)

include_directories(
  ../headers
  ../headers/mono # Mono libraries includes
  ../headers/VML # VML includes
)

# Patches for mscorlib internal calls
set (VML_MONO_PATCHES
  "patches/patches.c"
  "patches/patches.h"
  "patches/mono/metadata/file-io.c"
  "patches/mono/metadata/file-io.h"
  "patches/mono/metadata/icall.c"
  "patches/mono/metadata/icall.h"
)

if (USE_MONO_COMPILER)
  compile_mono_external_dll_aot(
    ASSEMBLY mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY Mono.Posix.dll
    REFERENCES System.dll mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY Mono.Security.dll
    REFERENCES mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY System.Configuration.dll
    REFERENCES System.Xml.dll System.Security.dll mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY System.Core.dll
    REFERENCES mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY System.Security.dll
    REFERENCES mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY System.Xml.dll
    REFERENCES mscorlib.dll
  )
  compile_mono_external_dll_aot(
    ASSEMBLY System.dll
    REFERENCES mscorlib.dll
  )

  add_custom_target(MonoCoreLibraries
    DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/mscorlib.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/Mono.Posix.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/Mono.Security.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/System.Configuration.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/System.Core.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/System.Security.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/System.Xml.dll.s
      ${CMAKE_CURRENT_BINARY_DIR}/System.dll.s
  )
endif ()

add_library(${PROJECT_NAME} STATIC
  main.c
  ${VML_MONO_PATCHES}
  mscorlib.dll.s
  Mono.Posix.dll.s
  Mono.Security.dll.s
  System.Configuration.dll.s
  System.Core.dll.s
  System.Security.dll.s
  System.Xml.dll.s
  System.dll.s
)

add_dependencies(${PROJECT_NAME} MonoCoreLibraries)
add_dependencies(${PROJECT_NAME} headers)

install(
  TARGETS ${PROJECT_NAME}
  DESTINATION lib
)