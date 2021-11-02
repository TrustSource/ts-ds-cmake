# ts-ds-cmake
Integrates TrustSource scanner with CMake

## Installation

Install the TrustSource scanner by following instructions from https://github.com/TrustSource/ts-deepscan  

The CMake module for the TrustSource scanner is probably best placed into a "cmake" subdirectory of your project source. If you use Git, clone this repository into the "cmake" subdirectory and add the path to the CMake module path in the root CMakeLists.txt file.

```
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/ts-ds-cmake")
```

## Usage

In order to add a scan target to the existing CMake target, include the TSScan module

```
include(TSScan)
```

And add the scan function call to a "CMakeLists.txt" file

```
ts_scan_target(<target_name> [INCLUDE_COPYRIGHT] [UPLOAD_RESULTS] [MODULE_NAME <module_name>])
```

The function creates a CMake target with the name "ts_scan_<target_name>". The scan can be executed by building this target. The scan results will be stored into the "scan.json" file in the target's build directory.

The scan function accepts optional parameters:

* __INCLUDE_COPYRIGHT__ - flag enabling the copyright analysis
* __UPLOAD_RESULTS__ - flag enabling uploading results to the TrustSource application
* __MODULE_NAME__ - name of the module used within the TrustSource application 

__NOTE__: in order to upload results, both parameters (__UPLOAD_RESULTS__ and __MODULE_NAME__) have to be set, additionally a TrustSource API key has to be stored in the variable __TS_SCAN_API_KEY__. Consider to pass it during the CMake configuration step:

```
cmake -DTS_SCAN_API_KEY=<your key> <source directory path>
```

## Next steps

Currently, the scanner scans all source files of the passed target and all source files of its dependencies, but only files added to targets in CMake. For the C and C++ projects it's however required to scan additionally all files that are included into source files that are actually built. This is now the work in progress and will be added into the next releases.       

## License

Please see [LICENSE](https://github.com/Trustsource/ts-ds-cmake/blob/main/LICENSE) for more information.