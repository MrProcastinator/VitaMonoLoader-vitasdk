#include <VML/VML.h>
#include <VML/VMLCoreAssemblies.h>

#include <mono/mini/jit.h>

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
    mono_aot_register_module(mono_aot_module_Mono_Posix_info);
    mono_aot_register_module(mono_aot_module_Mono_Security_info);
    mono_aot_register_module(mono_aot_module_mscorlib_info);
    mono_aot_register_module(mono_aot_module_System_Configuration_info);
    mono_aot_register_module(mono_aot_module_System_Core_info);
    mono_aot_register_module(mono_aot_module_System_Core_info);
    mono_aot_register_module(mono_aot_module_System_info);
    mono_aot_register_module(mono_aot_module_System_Security_info);
    mono_aot_register_module(mono_aot_module_System_Xml_info);
}