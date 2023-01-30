###############################################################################
# Find boost

find_package(boost_serialization REQUIRED)
find_package(boost_system REQUIRED)
find_package(boost_filesystem REQUIRED)
find_package(boost_thread REQUIRED)
find_package(boost_date_time REQUIRED)
find_package(boost_regex REQUIRED)
find_package(boost_chrono REQUIRED)
 
option(GTSAM_DISABLE_NEW_TIMERS "Disables using Boost.chrono for timing" OFF)
# Allow for not using the timer libraries on boost < 1.48 (GTSAM timing code falls back to old timer library)
set(GTSAM_BOOST_LIBRARIES
  boost_serialization
  boost_system
  boost_filesystem
  boost_thread
  boost_date_time
  boost_regex
)
if (GTSAM_DISABLE_NEW_TIMERS)
    message("WARNING:  GTSAM timing instrumentation manually disabled")
    list_append_cache(GTSAM_COMPILE_DEFINITIONS_PUBLIC DGTSAM_DISABLE_NEW_TIMERS)
else()
    if(Boost_TIMER_LIBRARY)
      list(APPEND GTSAM_BOOST_LIBRARIES boost_timer boost_chrono)
    else()
      list(APPEND GTSAM_BOOST_LIBRARIES rt) # When using the header-only boost timer library, need -lrt
      message("WARNING:  GTSAM timing instrumentation will use the older, less accurate, Boost timer library because boost older than 1.48 was found.")
    endif()
endif()
