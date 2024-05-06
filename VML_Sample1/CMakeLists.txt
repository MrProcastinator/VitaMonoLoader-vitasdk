enable_language(ASM)

project(VMLSample1)

# Add any additional include paths here
include_directories(
  ../headers
  ../headers/mono # Mono libraries includes
  ../headers/VML # VML includes
)

if(USE_MONO_COMPILER)
  compile_mono_single_assembly_aot(
    CODE_FILE Sample1
  )
endif()

## Build and link
# Add all the files needed to compile here
add_executable(${PROJECT_NAME}
  main.c
  Sample1.dll.s
)

add_dependencies(${PROJECT_NAME} headers SceLibcMonoBridge)

target_link_libraries(${PROJECT_NAME} VitaMonoLoader VMLCoreAssemblies)
target_link_libraries(${PROJECT_NAME} c m z)
target_link_libraries(${PROJECT_NAME} mathneon)
target_link_libraries(${PROJECT_NAME} SceLibDbg_stub SceLibKernel_stub SceAppMgr_stub SceAppUtil_stub SceCommonDialog_stub SceGxm_stub SceDisplay_stub SceSysmodule_stub)

target_link_libraries(${PROJECT_NAME} mono-vita_stub PTHREAD_PRX_stub SUPRXManager_stub_weak)
target_link_libraries(${PROJECT_NAME} SceSysmem_stub SceIofilemgr_stub SceRtc_stub SceAppUtil_stub SceNet_stub SceKernelThreadMgr_stub ${CMAKE_BINARY_DIR}/lib/SceLibcMonoBridge/stubs/libSceLibcMonoBridge_stub.a SceFios2_stub SceLibKernel_stub)
target_link_libraries(${PROJECT_NAME} vitashark SceShaccCgExt)
target_link_libraries(${PROJECT_NAME} taihen_stub SceShaccCg_stub SceKernelDmacMgr_stub)

set(VITA_APP_NAME "VML Sample 1")
set(VITA_TITLEID  "VMLSMPL01")
set(VITA_VPKNAME  "VMLSample1")
set(VITA_VERSION  "01.00")
set(VITA_MKSFOEX_FLAGS "-d ATTRIBUTE2=12")

vita_create_self(sample1-eboot.bin ${PROJECT_NAME} UNSAFE STRIPPED)
vita_create_vpk(${VITA_VPKNAME}.vpk ${VITA_TITLEID} sample1-eboot.bin
VERSION ${VITA_VERSION}
NAME ${VITA_APP_NAME}
  FILE 
    # VPK files
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/icon0.png sce_sys/icon0.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/Sample1/pic0.png sce_sys/pic0.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/startup.png sce_sys/livearea/contents/startup.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/Sample1/bg.png sce_sys/livearea/contents/bg.png
    ${CMAKE_SOURCE_DIR}/vpk/sce_sys/template.xml sce_sys/livearea/contents/template.xml
)
