#ifndef _VML_H_
#define _VML_H_

#ifdef _MSC_VER
#include <kernel.h>
#ifdef VML_BUILD
#define VML_EXPORT __declspec(dllexport)
#else
#define VML_EXPORT
#endif
#else
#include <vitasdk.h>
#define SCE_KERNEL_INDIVIDUAL_QUEUE_HIGHEST_PRIORITY	(64)
#define VML_EXPORT
#endif

typedef void(*VMLRootDomainEntry)();

typedef struct VMLInitOptParam {
	unsigned int stackSize;
	unsigned int cpuAffinity;
	unsigned int priority;
	const char* programName;
	int monoVerboseDebug;
} VMLInitOptParam;

VML_EXPORT int VMLInitialize(VMLRootDomainEntry domainEntry, VMLInitOptParam *pOptParam);

VML_EXPORT int VMLRunMain(const char *sMainDllPath, void **ppMainAotAssemblyInfo);

VML_EXPORT int VMLRegisterAssembly(void **ppAotAssemblyInfo);

VML_EXPORT int VMLEnd();

#ifndef _MSC_VER
VML_EXPORT void VMLSetPaths(const char* assembly_path, const char* config_path);
#endif

#endif
