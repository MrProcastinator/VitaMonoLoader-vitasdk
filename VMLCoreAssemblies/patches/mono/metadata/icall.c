#include "icall.h"

#include <mono/metadata/object.h>
#include <mono/metadata/exception.h>
#include <mono/metadata/appdomain.h>
#include <mono/metadata/marshal.h>
#include <mono/utils/strenc.h>

#define mono_string_chars(s) ((gunichar2*)(s)->chars)
#define mono_string_length(s) ((s)->length)

#include <vitasdk.h>

#include <ctype.h>
#include <stdint.h>

#include "../headers/VML/VML.h"

/*
    Original: ves_icall_System_Text_Encoding_InternalCodePage
    Problem: Due to not resolving exports _CType and _Tolotab, the operation results in a loop with causes several read exceptions
    Solution: hardcode utf-8 for now
*/
static MonoString*
vml_icall_System_Text_Encoding_InternalCodePage(gint32 *int_code_page)
{
    const char *cset;
	const char *p;
	char *c;
	char *codepage = NULL;
	int code;
	int i;

    *int_code_page = -1;

    cset = "utf_8";

    return mono_string_new (mono_domain_get (), cset);
}

/*
    Original: ves_icall_System_Environment_get_TickCount
    Problem: When calling this function, it tries to open the file /proc/uptime, which is not available in PSVita
    This causes a read exception and to avoid this overhead, we need to get the value directly from the kernel
    Solution: use SceRtc functions to skip the file read
*/
static gint32
ves_icall_System_Environment_get_TickCount (void)
{
    SceRtcTick tick;
    sceRtcGetCurrentTick(&tick);
    return (gint32) (tick.tick & 0xffffffff);
}

/*
    Original: ves_icall_System_Environment_GetEnvironmentVariable
    Problem: This function uses a custom environment, which is not accesible through other means and isnot
    interoperable with vitasdk
    Solution: Use VML implementation of getenv to retrieve environment variables
*/
static MonoString *
ves_icall_System_Environment_GetEnvironmentVariable (MonoString *name)
{
	const gchar *value;
	gchar *utf8_name;

	if (name == NULL)
		return NULL;

	utf8_name = mono_string_to_utf8 (name);
	value = VMLGetEnv (utf8_name);

	free (utf8_name);

	if (value == 0)
		return NULL;

	return mono_string_new (mono_domain_get (), value);
}

/*
    Original: ves_icall_System_Environment_InternalSetEnvironmentVariable
    Problem: This function uses a custom environment, which is not accesible through other meansand not
    interoperable with vitasdk
    Solution: Use VML implementation of setenv to set environment variables
*/
static void
ves_icall_System_Environment_InternalSetEnvironmentVariable (MonoString *name, MonoString *value)
{
	gchar *utf8_name, *utf8_value;

	utf8_name = mono_string_to_utf8 (name);

	if ((value == NULL) || (mono_string_length (value) == 0) || (mono_string_chars (value)[0] == 0)) {
		VMLUnsetEnv (utf8_name);
		free (utf8_name);
		return;
	}

	utf8_value = mono_string_to_utf8 (value);
	VMLSetEnv (utf8_name, utf8_value, TRUE);

	free (utf8_name);
	free (utf8_value);
}


void VMLICallApplyPatches()
{
    SCE_DBG_LOG_TRACE("Patching System.Text.Encoding::InternalCodePage...");
    mono_add_internal_call("System.Text.Encoding::InternalCodePage", vml_icall_System_Text_Encoding_InternalCodePage);
    SCE_DBG_LOG_TRACE("Patching System.Environment::get_TickCount...");
    mono_add_internal_call("System.Environment::get_TickCount", ves_icall_System_Environment_get_TickCount);
    SCE_DBG_LOG_TRACE("Patching System.Environment::internalGetEnvironmentVariable...");
    mono_add_internal_call("System.Environment::internalGetEnvironmentVariable", ves_icall_System_Environment_GetEnvironmentVariable);
    SCE_DBG_LOG_TRACE("Patching System.Environment::InternalSetEnvironmentVariable...");
    mono_add_internal_call("System.Environment::InternalSetEnvironmentVariable", ves_icall_System_Environment_InternalSetEnvironmentVariable);
}