/* ----------------------------------------------------------------------------

 * GTSAM Copyright 2010, Georgia Tech Research Corporation,
 * Atlanta, Georgia 30332-0415
 * All Rights Reserved
 * Authors: Frank Dellaert, et al. (see THANKS for the full author list)

 * See LICENSE for the license information

 * -------------------------------------------------------------------------- */

/**
 * @file     types.cpp
 * @brief    Functions for handling type information
 * @author   Varun Agrawal
 * @date     May 18, 2020
 * @ingroup base
 */

#include <gtsam/base/types.h>

#ifdef __GNUG__
#include <cstdlib>
#include <cxxabi.h>
#include <string>
#endif

namespace gtsam {

/// Pretty print Value type name
std::string demangle(const char* name) {
  // by default set to the original mangled name
  std::string demangled_name = std::string(name);

#ifdef __GNUG__
  // g++ version of demangle
  char* demangled = nullptr;
  int status = -1; // some arbitrary value to eliminate the compiler warning
  demangled = abi::__cxa_demangle(name, nullptr, nullptr, &status);

  demangled_name = (status == 0) ? std::string(demangled) : std::string(name);

  std::free(demangled);
#endif

  return demangled_name;
}

} /* namespace gtsam */
