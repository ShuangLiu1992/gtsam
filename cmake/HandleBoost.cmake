###############################################################################
# Find boost

find_package(Boost REQUIRED COMPONENTS 
  serialization
  system
  filesystem
  thread
  date_time
  regex
  concept_check
  timer
  chrono
  )
 
option(GTSAM_DISABLE_NEW_TIMERS "Disables using Boost.chrono for timing" OFF)
# Allow for not using the timer libraries on boost < 1.48 (GTSAM timing code falls back to old timer library)
set(GTSAM_BOOST_LIBRARIES
  Boost::serialization
  Boost::system
  Boost::filesystem
  Boost::thread
  Boost::date_time
  Boost::regex
  Boost::concept_check
)
if (GTSAM_DISABLE_NEW_TIMERS)
    message("WARNING:  GTSAM timing instrumentation manually disabled")
    list_append_cache(GTSAM_COMPILE_DEFINITIONS_PUBLIC DGTSAM_DISABLE_NEW_TIMERS)
else()
    if(TARGET Boost::timer)
      list(APPEND GTSAM_BOOST_LIBRARIES Boost::timer Boost::chrono)
    else()
      list(APPEND GTSAM_BOOST_LIBRARIES rt) # When using the header-only boost timer library, need -lrt
      message("WARNING:  GTSAM timing instrumentation will use the older, less accurate, Boost timer library because boost older than 1.48 was found.")
    endif()
endif()