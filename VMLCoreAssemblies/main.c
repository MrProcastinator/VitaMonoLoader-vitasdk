#include <vitasdk.h>

#include <VML/VML.h>
#include <VML/VMLCoreAssemblies.h>

#include <mono/mini/jit.h>

#include "patches/patches.h"

extern void** mono_aot_module_Mono_Posix_info;
extern void** mono_aot_module_Mono_Security_info;
extern void** mono_aot_module_mscorlib_info;
extern void** mono_aot_module_System_Configuration_info;
extern void** mono_aot_module_System_Core_info;
extern void** mono_aot_module_System_info;
extern void** mono_aot_module_System_Security_info;
extern void** mono_aot_module_System_Xml_info;

VML_EXPORT void VMLCoreAssembliesRegister()
{
    SCE_DBG_LOG_INFO("[VML] Loading assembly Mono.Posix...");
    mono_aot_register_module(mono_aot_module_Mono_Posix_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly Mono.Security...");
    mono_aot_register_module(mono_aot_module_Mono_Security_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly mscorlib...");
    mono_aot_register_module(mono_aot_module_mscorlib_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly System.Configuration...");
    mono_aot_register_module(mono_aot_module_System_Configuration_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly System.Core...");
    mono_aot_register_module(mono_aot_module_System_Core_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly System...");
    mono_aot_register_module(mono_aot_module_System_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly System.Security...");
    mono_aot_register_module(mono_aot_module_System_Security_info);
    SCE_DBG_LOG_INFO("[VML] Loading assembly System.Xml...");
    mono_aot_register_module(mono_aot_module_System_Xml_info);
}