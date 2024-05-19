#include "icall.h"

#include <mono/metadata/object.h>
#include <mono/metadata/exception.h>
#include <mono/metadata/appdomain.h>
#include <mono/metadata/marshal.h>
#include <mono/utils/strenc.h>

#include <vitasdk.h>

static const char* DEFAULT_CURRENT_DIRECTORY = "app0:";

/*
    Original: ves_icall_System_IO_MonoIO_GetCurrentDirectory
    Problem: Execution gives a FileNotFoundException, probably due to calling an unknown filename
    Solution: hardcode current directory to app0:
*/
MonoString *
vml_icall_System_IO_MonoIO_GetCurrentDirectory (gint32 *error)
{
	MonoString* result = mono_string_new (mono_domain_get (), DEFAULT_CURRENT_DIRECTORY);
	return result;
}

void VMLFileIOApplyPatches()
{
    SCE_DBG_LOG_TRACE("Patching System.IO.MonoIO::GetCurrentDirectory...");
    mono_add_internal_call("System.IO.MonoIO::GetCurrentDirectory", vml_icall_System_IO_MonoIO_GetCurrentDirectory);
}