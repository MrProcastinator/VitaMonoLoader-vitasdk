# VitaMonoLoader for vitasdk
Standalone mono loader for PS Vita, compatible with vitasdk, based on [this project](https://github.com/GrapheneCt/VitaMonoLoader).

## What's VitaMonoLoader?

This library allows any developer to use Mono for vita implementation to create .NET programs and load .NET assemblies in a native application for the PSVita. For core libraries, only NET 2.0 features are supported.

## Requirements

In order to use this library, you must have:
- A copy of any UnitySetup-Playstation-Vita-Support-for-Editor installer, supplied by Unity
- [Mono 2.11.4 for Windows](https://download.mono-project.com/archive/2.11.4/windows-installer/index.html)
- [Latest Mono release](https://www.mono-project.com/download/stable/) either for Windows or Linux
- Latest Python 3 release, with the following python libraries: [yaml](https://pypi.org/project/PyYAML/)
- Get vita-unmake-fself.exe and nids-extract.exe from [PSVita-RE-tools](https://github.com/MrProcastinator/PSVita-RE-tools.git)
- Access to a Windows machine to run the Unity mono compiler

In order to do the full compilation chain, either use an only Windows setup, or a Windows+WSL setup (recommended)

## Setup guide

### Host system side
1. Either, extract the contents of the ```UnitySetup-Playstation-Vita-Support-for-Editor``` installer (using any zip extractor and searching for a ```$INSTDIR$_59_``` folder), or install in Windows in any path.
2. Enter your Mono 2.11.4 installation folder and copy the lib\mono\2.0 folder as lib\mono\2.0-xcompiler
3. Open `mscorlib.dll` in 2.0-xcompiler with dnSpy
4. Find the class System.Environment
5. Change the value of mono_corlib_version from 105 to 89
6. Put vita-unmake-fself.exe and nids-extract.exe in a folder accesible through your PATH variable
7. When setting up your CMake folder, take into account the folder where the Unity Support files are stored (for SFV_FOLDER), and the 2.0-xcompiler folder (for MCS_PATH) (for more reference see [Build configuration](#build-configuration))
8. When cloning the project, execute the following git commands after:
   ```sh
   git submodule init
   git submodule update --init
   ```
9. Execute the following commands in your build folder:
   ```sh
   make
   make headers # Install mono headers in /include
   sudo make install
   ```

### PSVita system side
1. Download and install [CapUnlocker](https://github.com/GrapheneCt/CapUnlocker) plugin
2. Copy the following files from the folder `Data\Modules` inside the Unity Support for Vita folder to `ur0:data/VML`:
    
    - mono-vita.suprx
    - pthread.suprx
    - SUPRXManager.suprx
   
~~3. Copy the following files from the folder `sce_module` inside the Unity Support for Vita folder to `ur0:data/VML` (not needed to run on Vita3K): libc.suprx, libfios2.suprx~~
[This step is no longer needed](https://github.com/MrProcastinator/VitaMonoLoader-vitasdk/commit/40b43ee24536397f1fd8e95c5b925e6c2698660d)

## How to use

### Compile C# code

#### Manually
1. Compile your C# code to managed .dll by executing: ```mcs -sdk:2 -target:library -out:<MyDllName>.dll <MySrcName>.cs```
2. Compile your managed .dll to AOT assembly .s by executing: ```mono-xcompiler.exe --aot=full,asmonly,nodebug,static <MyDllName>.dll```
3. Add AOT assembly .s files as compile targets in your Vita app project
4. __Your PSVita application must be compiled in ARM mode:__ (compile with -marm)

#### Using CMake

You can use the VMLBuild.cmake plugin provided in this project to compile directly, using the following supported functions:

__For step 1__

- `compile_mono_single_assembly_aot(ASSEMBLY CODE_FILE)`
- `compile_mono_assembly_aot(ASSEMBLY CONFIG SOURCES REFERENCES FLAGS RESOURCES DEFINES)`

__For step 2__

- `compile_mono_dll_aot(DLL_FILE)`
- `compile_mono_external_dll_aot(ASSEMBLY TARGET LIBPATH REFERENCES)`
- `compile_mono_external_import(ASSEMBLY TARGET LIBPATH)`

For more information about these calls, refer to the [VML CMake Script Readme](https://github.com/MrProcastinator/VML-CMakeScripts)

Example of the whole circuit for `Example.dll`, using `System.Text.dll` and `Newtonsoft.Json.dll`:

```cmake
compile_mono_assembly_aot(
  SOURCES Program.cs Example.cs
  ASSEMBLY Example // Generates Example.dll assembly
  REFERENCES System.Text.dll
  DEFINES ARM_ARCH
)

# From mono core library
compile_mono_external_dll_aot(
  ASSEMBLY System.Text.dll
  REFERENCES mscorlib.dll
)

add_custom_target(MonoDeps
    DEPENDS
      ${CMAKE_CURRENT_BINARY_DIR}/System.Text.dll.s
)

# From external source
add_custom_target(ExternalDeps)

compile_mono_external_import(
    ASSEMBLY NewtonSoft.Json.dll
    TARGET ExternalDeps
)

add_executable(Example
  main.c
  System.Text.dll.s
  Example.dll.s
)

add_dependencies(Example MonoDeps)
add_dependencies(Example ExternalDeps)

target_link_libraries(Example VMLNewtonSoftJson)
```

### Using AOT assembly on PSVita

#### Using dependency assemblies

1. Copy managed .dll file to ```app0:VML```
2. Add AOT assembly .s file as dependencies for your project (if using VMLBuild.cmake add the .s file names to `create_executable`)
3. To load AOT assembly on PSVita, call:

```
extern void** mono_aot_module_<MyDllName>_info;

VMLRegisterAssembly(mono_aot_module_<MyDllName>_info);
```
For example:

```
extern void** mono_aot_module_AwesomeShmupGame_info;

VMLRegisterAssembly(mono_aot_module_AwesomeShmupGame_info);
```
NOTE: non alphanumeric characters inside an assembly name (like '.') are translated as '_' (System.Xml => System_Xml)

#### Binding native calls

If your C# module needs to access native PSVita functionality, you can do it using the `[MethodImpl(MethodImplOptions.InternalCall)]` feature in the C# code, and `mono_add_internal_call` in the native code (for more information, read [this info](https://www.mono-project.com/docs/advanced/pinvoke/))

For example:

__In Example.cs__

```csharp
public class Example
{
    [MethodImpl(MethodImplOptions.InternalCall)]
    public static extern int Sum(int a, int b);
}
```

__In Example.c__

```c
#include <vitasdk.h>

#include <stdint.h>

#include <mono/metadata/appdomain.h>
#include <mono/mini/jit.h>

int32_t sum(int32_t a, int32_t b)
{
    return a + b;
}

extern void** mono_aot_module_Example_info;

void VMLExampleRegister()
{
    mono_aot_register_module(mono_aot_module_Example_info);

    mono_add_internal_call("Example::Sum", example);
}
```

__In main.c__

```c
void rootEntry()
{
    VMLExampleRegister();

	int ret = VMLRunMain(ASSEMBLIES_DLL_FILE, mono_aot_module_Game_info);
}

int main()
{
    // ...
    ret = VMLInitialize(rootEntry, &optParam);
    // ...
}
```

## Examples

This repository contains some examples to help you get started with VitaMonoLoader use:
- VML_Sample1: Simple return example
- VML_Sample2: example of Vita2D bindings usage on mono

## RETools

RETools is a module for VitaMonoLoader to simplify the generation of libraries like VMLCoreAssemblies. As __this library attemps to not include any Unity assembly or AOT file__, you must provide the following files for development:
    - libMONO_stub.a
    - libPTHREAD_PRX_stub.a
    - libSUPRXManager_stub_weak.a
    - libSceCLibMonoBridge_stub.a
These files are already provided by Unity Support for Vita, but in SCE SDK format, which is not compatible with vitasdk. ReTools allows to convert these files and generate the appropiate stubs to build any VitaMonoLoader application.

## Build configuration

This template provides a set of CMake variables to allow build customization according to your development environment.

### VitaMonoLoader specific variables

| **CMake Variable**        | **Description**
|:-------------------|:------------------------------------------
|`SFV_FOLDER`         | Unity Support for Vita installation folder (mandatory)
|`MCS_PATH`         | Mono 2 compatible library folder (mandatory)
|`MONO_PATH` | Unity Support for Vita Mono library path (mandatory, should be inside Tools/MonoPSP2)
|`MONO_LIB_DLL_PATH` | Path to the vitasdk include folder containing VML initialization headers (default: lib/mono)
|`MONO_LIB_VML_PATH` | Path to the vitasdk lib folder containing VML binding libraries (default: lib)
|`USE_MONO_COMPILER` | Use mono compiler to generate AOT files (needed if no AOT files are present)
|`USE_CUSTOM_LIBC` | Use sce_module libraries from Unity Support for Vita

### Retools specific variables

| **CMake Variable**        | **Description**
|:-------------------|:------------------------------------------
|`USE_RE_TOOLS`         | Generate vitasdk format stubs automatically using RE Tools
|`RE_TOOL_VITA_UNMAKE_FSELF`         | Path to vita-unmake-fself tool
|`RE_TOOL_NIDS_EXTRACT` | Path to nids-extract tool
|`RE_TOOL_VITA_LIBS_GEN` | Path to vita-libs-gen tool

## TODO

- Create a wiki to document everything needed to fully understand VitaMonoLoader
