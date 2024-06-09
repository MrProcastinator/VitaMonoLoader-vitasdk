enable_language(ASM)

project(VMLSample2)

# Add any additional include paths here
include_directories(
  ../headers
  ../headers/mono # Mono libraries includes
  ../headers/VML # VML includes
)

if(USE_MONO_COMPILER)
  compile_mono_single_assembly_aot(
    CODE_FILE Sample2
    REFERENCES Vita2D.dll
  )
endif()

## Build and link
# Add all the files needed to compile here
add_executable(${PROJECT_NAME}
  main.c
  Sample2.dll.s
)

add_dependencies(${PROJECT_NAME} headers SceLibcMonoBridge ${MONO_STUBS_DEPENDENCIES})

target_link_libraries(${PROJECT_NAME} VitaMonoLoader VMLCoreAssemblies)
target_link_libraries(${PROJECT_NAME} VMLVita2D vita2d)
target_link_libraries(${PROJECT_NAME} c m z)
target_link_libraries(${PROJECT_NAME} mathneon)
target_link_libraries(${PROJECT_NAME} SceLibDbg_stub SceLibKernel_stub SceAppMgr_stub SceAppUtil_stub SceCommonDialog_stub SceGxm_stub SceDisplay_stub SceSysmodule_stub)

target_link_libraries(${PROJECT_NAME} ${MONO_VITA_STUBS} ${PTHREAD_STUBS} ${SUPRXMANAGER_STUBS})
target_link_libraries(${PROJECT_NAME} ScePgf_stub SceSysmem_stub SceIofilemgr_stub SceRtc_stub SceAppUtil_stub SceNet_stub SceKernelThreadMgr_stub ${SCELIBC_LIBRARY} SceFios2_stub SceLibKernel_stub)
target_link_libraries(${PROJECT_NAME} vitashark SceShaccCgExt)
target_link_libraries(${PROJECT_NAME} taihen_stub SceShaccCg_stub SceKernelDmacMgr_stub)

set(VITA_APP_NAME "VML Sample 2")
set(VITA_TITLEID  "VMLSMPL02")
set(VITA_VPKNAME  "VMLSample2")
set(VITA_VERSION  "01.00")
set(VITA_MKSFOEX_FLAGS "-d ATTRIBUTE2=12")

# Hack to avoid duplicate title id
set(VITA_MKSFOEX_FLAGS "")
set(VITA_PACK_VPK_FLAGS "")

vita_create_self(sample2-eboot.bin ${PROJECT_NAME} UNSAFE STRIPPED)
vita_create_vpk(${VITA_VPKNAME}.vpk ${VITA_TITLEID} sample2-eboot.bin
VERSION ${VITA_VERSION}
NAME ${VITA_APP_NAME}
  FILE 
    # VPK files
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/icon0.png sce_sys/icon0.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/Sample2/pic0.png sce_sys/pic0.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/startup.png sce_sys/livearea/contents/startup.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/Sample2/bg.png sce_sys/livearea/contents/bg.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/template.xml sce_sys/livearea/contents/template.xml
)

add_custom_target(VMLSample2_send_v3k
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_BINARY_DIR}/Sample2.dll
    ${VITA3K_PATH}/ux0/data/VML/Sample2.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_BINARY_DIR}/sample2-eboot.bin
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/eboot.bin
  DEPENDS ${VITA_VPKNAME}.vpk-vpk ${CMAKE_BINARY_DIR}/Sample2.dll
)
