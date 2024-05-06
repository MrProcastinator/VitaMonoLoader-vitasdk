#ifndef __G_MODULE_WINDOWS_INTERNALS_H__
#define __G_MODULE_WINDOWS_INTERNALS_H__

#include <mono/config.h>
#include <mono/eglib/glib.h>

#ifdef G_OS_WIN32
#include <gmodule.h>

gpointer
w32_find_symbol (const gchar *symbol_name);
#endif /* G_OS_WIN32 */
#endif /* __G_MODULE_WINDOWS_INTERNALS_H__ */
