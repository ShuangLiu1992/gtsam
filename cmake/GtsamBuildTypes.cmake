include(CheckCXXCompilerFlag) # for check_cxx_compiler_flag()

# Set cmake policy to recognize the Apple Clang compiler
# independently from the Clang compiler.
if(POLICY CMP0025)
  cmake_policy(SET CMP0025 NEW)
endif()

# function:  list_append_cache(var [new_values ...])
# Like "list(APPEND ...)" but working for CACHE variables.
# -----------------------------------------------------------
function(list_append_cache var)
  set(cur_value ${${var}})
  list(APPEND cur_value ${ARGN})
  get_property(MYVAR_DOCSTRING CACHE ${var} PROPERTY HELPSTRING)
  set(${var} "${cur_value}" CACHE STRING "${MYVAR_DOCSTRING}" FORCE)
endfunction()

# function:  append_config_if_not_empty(TARGET_VARIABLE build_type)
# Auxiliary function used to merge configuration-specific flags into the
# global variables that will actually be send to cmake targets.
# -----------------------------------------------------------
function(append_config_if_not_empty TARGET_VARIABLE_ build_type)
  string(TOUPPER "${build_type}" build_type_toupper)
  set(flags_variable_name "${TARGET_VARIABLE_}_${build_type_toupper}")
  set(flags_ ${${flags_variable_name}})
  if (NOT "${flags_}" STREQUAL "")
    if (${build_type_toupper} STREQUAL "COMMON")
      # Special "COMMON" configuration type, just append without CMake expression:
      list_append_cache(${TARGET_VARIABLE_} "${flags_}")
    else()
      # Regular configuration type:
      list_append_cache(${TARGET_VARIABLE_} "$<$<CONFIG:${build_type}>:${flags_}>")
    endif()
  endif()
endfunction()


# Add install prefix to search path
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_INSTALL_PREFIX}")


# Set up build types for MSVC and XCode
set(GTSAM_CMAKE_CONFIGURATION_TYPES Debug Release Timing Profiling RelWithDebInfo MinSizeRel
      CACHE STRING "Build types available to MSVC and XCode")
mark_as_advanced(FORCE GTSAM_CMAKE_CONFIGURATION_TYPES)
set(CMAKE_CONFIGURATION_TYPES ${GTSAM_CMAKE_CONFIGURATION_TYPES} CACHE STRING "Build configurations" FORCE)


# Default to Release mode
if(NOT CMAKE_BUILD_TYPE AND NOT MSVC AND NOT XCODE_VERSION)
    set(GTSAM_CMAKE_BUILD_TYPE "Release" CACHE STRING
      "Choose the type of build, options are: None Debug Release Timing Profiling RelWithDebInfo.")
    set(CMAKE_BUILD_TYPE ${GTSAM_CMAKE_BUILD_TYPE} CACHE STRING
      "Choose the type of build, options are: None Debug Release Timing Profiling RelWithDebInfo." FORCE)
endif()

# Define all cache variables, to be populated below depending on the OS/compiler:
set(GTSAM_COMPILE_OPTIONS_PRIVATE        "" CACHE INTERNAL "(Do not edit) Private compiler flags for all build configurations." FORCE)
set(GTSAM_COMPILE_OPTIONS_PUBLIC         "" CACHE INTERNAL "(Do not edit) Public compiler flags (exported to user projects) for all build configurations."  FORCE)
set(GTSAM_COMPILE_DEFINITIONS_PRIVATE    "" CACHE INTERNAL "(Do not edit) Private preprocessor macros for all build configurations." FORCE)
set(GTSAM_COMPILE_DEFINITIONS_PUBLIC     "" CACHE INTERNAL "(Do not edit) Public preprocessor macros for all build configurations." FORCE)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PUBLIC)
mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PRIVATE)
mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PUBLIC)

foreach(build_type ${GTSAM_CMAKE_CONFIGURATION_TYPES})
  string(TOUPPER "${build_type}" build_type_toupper)

  # Define empty cache variables for "public". "private" are created below.
  set(GTSAM_COMPILE_OPTIONS_PUBLIC_${build_type_toupper}      "" CACHE STRING "(User editable) Public compiler flags (exported to user projects) for `${build_type_toupper}` configuration.")
  set(GTSAM_COMPILE_DEFINITIONS_PUBLIC_${build_type_toupper}  "" CACHE STRING "(User editable) Public preprocessor macros for `${build_type_toupper}` configuration.")
endforeach()

# Common preprocessor macros for each configuration:
set(GTSAM_COMPILE_DEFINITIONS_PRIVATE_DEBUG           "_DEBUG;EIGEN_INITIALIZE_MATRICES_BY_NAN" CACHE STRING "(User editable) Private preprocessor macros for Debug configuration.")
set(GTSAM_COMPILE_DEFINITIONS_PRIVATE_RELWITHDEBINFO  "NDEBUG" CACHE STRING "(User editable) Private preprocessor macros for RelWithDebInfo configuration.")
set(GTSAM_COMPILE_DEFINITIONS_PRIVATE_RELEASE         "NDEBUG" CACHE STRING "(User editable) Private preprocessor macros for Release configuration.")
set(GTSAM_COMPILE_DEFINITIONS_PRIVATE_PROFILING       "NDEBUG" CACHE STRING "(User editable) Private preprocessor macros for Profiling configuration.")
set(GTSAM_COMPILE_DEFINITIONS_PRIVATE_TIMING          "NDEBUG;ENABLE_TIMING" CACHE STRING "(User editable) Private preprocessor macros for Timing configuration.")

mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PRIVATE_DEBUG)
mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PRIVATE_RELWITHDEBINFO)
mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PRIVATE_RELEASE)
mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PRIVATE_PROFILING)
mark_as_advanced(GTSAM_COMPILE_DEFINITIONS_PRIVATE_TIMING)

mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE_COMMON)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE_DEBUG)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE_RELWITHDEBINFO)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE_RELEASE)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE_PROFILING)
mark_as_advanced(GTSAM_COMPILE_OPTIONS_PRIVATE_TIMING)

# Merge all user-defined flags into the variables that are to be actually used by CMake:
foreach(build_type "common" ${GTSAM_CMAKE_CONFIGURATION_TYPES})
  append_config_if_not_empty(GTSAM_COMPILE_OPTIONS_PRIVATE ${build_type})
  append_config_if_not_empty(GTSAM_COMPILE_OPTIONS_PUBLIC  ${build_type})
  append_config_if_not_empty(GTSAM_COMPILE_DEFINITIONS_PRIVATE  ${build_type})
  append_config_if_not_empty(GTSAM_COMPILE_DEFINITIONS_PUBLIC   ${build_type})
endforeach()

# Linker flags:
set(GTSAM_CMAKE_SHARED_LINKER_FLAGS_TIMING  "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags during timing builds.")
set(GTSAM_CMAKE_MODULE_LINKER_FLAGS_TIMING  "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags during timing builds.")
set(GTSAM_CMAKE_EXE_LINKER_FLAGS_TIMING     "${CMAKE_EXE_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags during timing builds.")

set(GTSAM_CMAKE_SHARED_LINKER_FLAGS_PROFILING "${CMAKE_SHARED_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags during profiling builds.")
set(GTSAM_CMAKE_MODULE_LINKER_FLAGS_PROFILING "${CMAKE_MODULE_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags during profiling builds.")
set(GTSAM_CMAKE_EXE_LINKER_FLAGS_PROFILING    "${CMAKE_EXE_LINKER_FLAGS_RELEASE}" CACHE STRING "Linker flags during profiling builds.")

mark_as_advanced(GTSAM_CMAKE_EXE_LINKER_FLAGS_TIMING
                 GTSAM_CMAKE_SHARED_LINKER_FLAGS_TIMING GTSAM_CMAKE_MODULE_LINKER_FLAGS_TIMING
                 GTSAM_CMAKE_C_FLAGS_PROFILING GTSAM_ GTSAM_CMAKE_EXE_LINKER_FLAGS_PROFILING
                 GTSAM_CMAKE_SHARED_LINKER_FLAGS_PROFILING GTSAM_CMAKE_MODULE_LINKER_FLAGS_PROFILING)

set(CMAKE_SHARED_LINKER_FLAGS_TIMING ${GTSAM_CMAKE_SHARED_LINKER_FLAGS_TIMING})
set(CMAKE_MODULE_LINKER_FLAGS_TIMING ${GTSAM_CMAKE_MODULE_LINKER_FLAGS_TIMING})
set(CMAKE_EXE_LINKER_FLAGS_TIMING ${GTSAM_CMAKE_EXE_LINKER_FLAGS_TIMING})

set(CMAKE_SHARED_LINKER_FLAGS_PROFILING ${GTSAM_CMAKE_SHARED_LINKER_FLAGS_PROFILING})
set(CMAKE_MODULE_LINKER_FLAGS_PROFILING ${GTSAM_CMAKE_MODULE_LINKER_FLAGS_PROFILING})
set(CMAKE_EXE_LINKER_FLAGS_PROFILING ${GTSAM_CMAKE_EXE_LINKER_FLAGS_PROFILING})

if(MSVC)
  list_append_cache(GTSAM_COMPILE_DEFINITIONS_PUBLIC
          _ENABLE_EXTENDED_ALIGNED_STORAGE
  )
endif ()

# Applies the per-config build flags to the given target (e.g. gtsam, wrap_lib)
function(gtsam_apply_build_flags target_name_)
  # To enable C++11: the use of target_compile_features() is preferred since
  # it will be not in conflict with a more modern C++ standard, if used in a
  # client program.
  if (NOT "${GTSAM_COMPILE_FEATURES_PUBLIC}" STREQUAL "")
  	target_compile_features(${target_name_} PUBLIC ${GTSAM_COMPILE_FEATURES_PUBLIC})
  endif()

  target_compile_definitions(${target_name_} PRIVATE ${GTSAM_COMPILE_DEFINITIONS_PRIVATE})
  target_compile_definitions(${target_name_} PUBLIC ${GTSAM_COMPILE_DEFINITIONS_PUBLIC})
  if (NOT "${GTSAM_COMPILE_OPTIONS_PUBLIC}" STREQUAL "")
    target_compile_options(${target_name_} PUBLIC ${GTSAM_COMPILE_OPTIONS_PUBLIC})
  endif()
  target_compile_options(${target_name_} PRIVATE ${GTSAM_COMPILE_OPTIONS_PRIVATE})

endfunction(gtsam_apply_build_flags)


if(NOT MSVC AND NOT XCODE_VERSION)
  # Set the build type to upper case for downstream use
  string(TOUPPER "${CMAKE_BUILD_TYPE}" CMAKE_BUILD_TYPE_UPPER)

  # Set the GTSAM_BUILD_TAG variable.
  # If build type is Release, set to blank (""), else set to the build type.
  if(${CMAKE_BUILD_TYPE_UPPER} STREQUAL "RELEASE")
   set(GTSAM_BUILD_TAG "") # Don't create release mode tag on installed directory
  else()
   set(GTSAM_BUILD_TAG "${CMAKE_BUILD_TYPE}")
  endif()
endif()
