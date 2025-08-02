#include <vitasdk.h>

#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include "../headers/VML/VML.h"

static char **VML_env = (char **) 0;

VML_EXPORT char* VMLGetEnv(const char* name)
{
    size_t i;
    size_t len;
    char* value = NULL;

	if (!name || *name == '\0' || strchr(name, '=') != NULL) {
		SCE_DBG_LOG_ERROR("VMLGetEnv: name is invalid\n");
		return NULL;
	}

    if (VML_env) {
        len = strlen(name);
        for (i = 0; VML_env[i] && !value; ++i) {
            if ((strncmp(VML_env[i], name, len) == 0) &&
                (VML_env[i][len] == '=')) {
                value = &VML_env[i][len + 1];
            }
        }
    }
	return value;
}

VML_EXPORT int VMLSetEnv(const char *name, const char *value, int overwrite)
{
    int added;
    size_t len, i;
    char **new_env;
    char *new_variable;

    if (!name || *name == '\0' || strchr(name, '=') != NULL || !value) {
        SCE_DBG_LOG_ERROR("VMLSetEnv: name is invalid\n");
        return (-1);
    }

    if (!overwrite && VMLGetEnv(name)) {
        SCE_DBG_LOG_INFO("VMLSetEnv: '%s' is already present: skipping...\n", name);
        return 0;
    }

    len = strlen(name) + strlen(value) + 2;
    new_variable = (char *) malloc(len);
    if (!new_variable) {
        return (-1);
    }

    snprintf(new_variable, len, "%s=%s", name, value);
    value = new_variable + strlen(name) + 1;
    name = new_variable;

    added = 0;
    i = 0;
    if (VML_env) {
        len = (value - name);
        for (; VML_env[i]; ++i) {
            if (strncmp(VML_env[i], name, len) == 0) {
                break;
            }
        }
        if (VML_env[i]) {
            free(VML_env[i]);
            VML_env[i] = new_variable;
            added = 1;
        }
    }

    if (!added) {
        new_env = realloc(VML_env, (i + 2) * sizeof(char *));
        if (new_env) {
            VML_env = new_env;
            VML_env[i++] = new_variable;
            VML_env[i++] = (char *) 0;
            added = 1;
        } else {
            free(new_variable);
        }
    }
    return (added ? 0 : -1);
}

VML_EXPORT int VMLUnsetEnv(const char *name)
{
    size_t i, j;
    size_t len;

    if (!name || *name == '\0' || strchr(name, '=') != NULL) {
        SCE_DBG_LOG_ERROR("VMLUnsetEnv: name is invalid\n");
        return (-1);
    }

    len = strlen(name);
    if (VML_env) {
        for (i = 0; VML_env[i]; ++i) {
            if (strncmp(VML_env[i], name, len) == 0 && VML_env[i][len] == '=') {
                free(VML_env[i]);
                for (j = i; VML_env[j]; ++j) {
                    VML_env[j] = VML_env[j + 1];
                }
                return 0;
            }
        }
    }
    return -1;
}

/* For libc compatibility */
char* getenv(const char* name) {
    return VMLGetEnv(name);
}

int setenv(const char* name, const char* value, int overwrite) {
    return VMLSetEnv(name, value, overwrite);
}

int unsetenv(const char* name) {
    return VMLUnsetEnv(name);
}