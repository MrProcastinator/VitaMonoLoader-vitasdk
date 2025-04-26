#include "icall.h"

#include <mono/metadata/object.h>
#include <mono/metadata/exception.h>
#include <mono/metadata/appdomain.h>
#include <mono/metadata/marshal.h>
#include <mono/utils/strenc.h>

#include <vitasdk.h>

#include <ctype.h>
#include <stdint.h>

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


void VMLICallApplyPatches()
{
    SCE_DBG_LOG_TRACE("Patching System.Text.Encoding::InternalCodePage...");
    mono_add_internal_call("System.Text.Encoding::InternalCodePage", vml_icall_System_Text_Encoding_InternalCodePage);
    mono_add_internal_call("System.Environment::get_TickCount", ves_icall_System_Environment_get_TickCount);
}