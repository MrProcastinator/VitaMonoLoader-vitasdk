/**
 * \file
 */

#ifndef __MONO_UTILS_DL_WINDOWS_H__
#define __MONO_UTILS_DL_WINDOWS_H__

#include <mono/config.h>
#include <mono/eglib/glib.h>

#ifdef HOST_WIN32
#include "mono/utils/mono-dl.h"

void*
mono_dl_lookup_symbol_in_process (const char *symbol_name);
#endif /* HOST_WIN32 */
#endif /* __MONO_UTILS_DL_WINDOWS_H__ */

