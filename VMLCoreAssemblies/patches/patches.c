#include "patches.h"

#include "mono/metadata/icall.h"
#include "mono/metadata/file-io.h"

void VMLCoreAssembliesApplyPatches()
{
    VMLICallApplyPatches();
    VMLFileIOApplyPatches();
}