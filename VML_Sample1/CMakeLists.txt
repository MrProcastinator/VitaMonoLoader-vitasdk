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

set(VML_FILES "")
get_mono_files(VML_FILES)

## Build and link
# Add all the files needed to compile here
add_executable(${PROJECT_NAME}
  main.c
  Sample1.dll.s
)

add_dependencies(${PROJECT_NAME} headers SceLibcMonoBridge ${MONO_STUBS_DEPENDENCIES})

target_link_libraries(${PROJECT_NAME} VitaMonoLoader VMLCoreAssemblies)
target_link_libraries(${PROJECT_NAME} c m z)
target_link_libraries(${PROJECT_NAME} mathneon)
target_link_libraries(${PROJECT_NAME} SceLibDbg_stub SceLibKernel_stub SceAppMgr_stub SceAppUtil_stub SceCommonDialog_stub SceGxm_stub SceDisplay_stub SceSysmodule_stub)

target_link_libraries(${PROJECT_NAME} ${MONO_VITA_STUBS} ${PTHREAD_STUBS} ${SUPRXMANAGER_STUBS})
target_link_libraries(${PROJECT_NAME} SceSysmem_stub SceIofilemgr_stub SceRtc_stub SceAppUtil_stub SceNet_stub SceKernelThreadMgr_stub ${SCELIBC_LIBRARY} SceFios2_stub SceLibKernel_stub)
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
    # Mono files
    ${CMAKE_BINARY_DIR}/Sample1.dll VML/Sample1.dll
    ${VML_FILES}    
)

add_custom_target(VMLSample1_send_v3k
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/Mono.Posix.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/Mono.Posix.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/Mono.Security.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/Mono.Security.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/System.Configuration.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/System.Configuration.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/System.Core.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/System.Core.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/System.Security.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/System.Security.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/System.Xml.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/System.Xml.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/System.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/System.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${SFV_FOLDER}/Tools/MonoPSP2/mscorlib.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/mscorlib.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_BINARY_DIR}/Sample1.dll
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/VML/Sample1.dll
  COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_CURRENT_BINARY_DIR}/sample1-eboot.bin
    ${VITA3K_PATH}/ux0/app/${VITA_TITLEID}/eboot.bin
  DEPENDS ${VITA_VPKNAME}.vpk-vpk ${CMAKE_BINARY_DIR}/Sample1.dll
)
