cmake_minimum_required(VERSION 3.4)

function (_get_link_dependencies deps target)
    set(_deps ${${deps}})
    if (TARGET ${target})
        list(APPEND _deps ${target})

        get_target_property(_is_imported ${target} IMPORTED)        
        if (_is_imported)
            get_target_property(_target_deps ${target} INTERFACE_LINK_LIBRARIES)
        else()
            get_target_property(_target_deps ${target} LINK_LIBRARIES)
        endif()

        foreach(_dep IN LISTS _target_deps)
            if (NOT _dep IN_LIST _deps)
                _get_link_dependencies(_deps ${_dep})
            endif()
        endforeach()
    endif()
    set(${deps} "${_deps}" PARENT_SCOPE)
endfunction()


function (ts_scan_target target)
    set(options UPLOAD_RESULTS INCLUDE_COPYRIGHT)
    set(one_args MODULE_NAME)
    cmake_parse_arguments(TS_SCAN_TARGET "${options}" "${one_args}" "" ${ARGN})

    find_program(ts-deepscan "ts-deepscan")
    if("${ts-deepscan}" STREQUAL "ts-deepscan-NOTFOUND")
        message(FATAL_ERROR "Can't find ts-deepscan tool. Please install the tool first. More info at https://github.com/TrustSource/ts-deepscan")
    else()
        message(STATUS "Found ts-deepscan tool: ${ts-deepscan}")
    endif()

    set(_sources)
    _get_link_dependencies(_target_deps ${target})
    
    foreach(_dep IN LISTS _target_deps)
      get_target_property(_dep_sources ${_dep} SOURCES)
      foreach(_dep_src IN LISTS _dep_sources)
        if(NOT IS_ABSOLUTE ${_dep_src})
            get_target_property(_dep_dir ${_dep} SOURCE_DIR)
            set(_dep_src "${_dep_dir}/${_dep_src}")
        endif()        
        list(APPEND _sources ${_dep_src})
      endforeach()
    endforeach()   
    
    set(_flags "--filterFiles")
    list(APPEND _flags  "-o" "scan.json")

    if(TS_SCAN_TARGET_INCLUDE_COPYRIGHT)
        list(APPEND _flags "--includeCopyright")
    endif()

    if(TS_SCAN_TARGET_UPLOAD_RESULTS)
        if("${TS_SCAN_TARGET_MODULE_NAME}" STREQUAL "")
            message(FATAL_ERROR "Module name is not specified")
        endif()        
        list(APPEND _flags "--moduleName" "${TS_SCAN_TARGET_MODULE_NAME}")

        if(NOT DEFINED TS_SCAN_API_KEY)
            message(FATAL_ERROR "TrustSource API key is not defined. Please set TS_SCAN_API_KEY variable.")
        endif()
        list(APPEND _flags "--apiKey" "${TS_SCAN_API_KEY}")

        list(APPEND _flags "--upload")
    endif()

    # Add scan target
    add_custom_target(ts_scan_${target} COMMAND ${ts-deepscan} ${_sources} ${_flags} )
endfunction()