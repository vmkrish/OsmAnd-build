set(CMAKE_SYSTEM_NAME QNX)
set(CMAKE_SYSTEM_VERSION 8.0.0)
set(CMAKE_SYSTEM_PROCESSOR armv7)
set(CMAKE_TARGET_OS qnx)
set(CMAKE_TARGET_CPU_ARCH arm)
set(CMAKE_SHARED_LIBS_ALLOWED_ON_TARGET FALSE)
set(CMAKE_STATIC_LIBS_ALLOWED_ON_TARGET TRUE)
set(CMAKE_COMPILER_FAMILY gcc)

set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".so")
set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")

if(CMAKE_HOST_WIN32)
  set(HOST_EXECUTABLE_SUFFIX ".exe")
endif(CMAKE_HOST_WIN32)

find_path(QNX_HOST
  NAME usr/bin/qcc${HOST_EXECUTABLE_SUFFIX}
  PATHS $ENV{QNX_HOST}
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
)
  
find_path(QNX_TARGET
  NAME usr/include/qnx_errno.h
  PATHS $ENV{QNX_TARGET}
  NO_CMAKE_PATH
  NO_CMAKE_ENVIRONMENT_PATH
)

set(CMAKE_C_COMPILER ${QNX_HOST}/usr/bin/qcc${HOST_EXECUTABLE_SUFFIX})
set(CMAKE_CXX_COMPILER ${QNX_HOST}/usr/bin/QCC${HOST_EXECUTABLE_SUFFIX})

# Use gcc 4.6.3 with GNU library instead on dinkum; enable C++11 support
set(CMAKE_COMPILER_C_FLAGS "-V4.6.3,gcc_ntoarmv7le_gpp -lang-c")
set(CMAKE_COMPILER_CXX_FLAGS "-V4.6.3,gcc_ntoarmv7le_gpp -lang-c++ -Wc,-std=gnu++0x")

# Use QNX Neutrino ARM toolchain
set(CMAKE_MAKE_PROGRAM "${QNX_HOST}/usr/bin/make${HOST_EXECUTABLE_SUFFIX}"                                  CACHE PATH "make" FORCE)
set(CMAKE_SH           "${QNX_HOST}/usr/bin/sh${HOST_EXECUTABLE_SUFFIX}"                                    CACHE PATH "sh" FORCE)
set(CMAKE_AR           "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-ar${HOST_EXECUTABLE_SUFFIX}"       CACHE PATH "archive" FORCE)
set(CMAKE_RANLIB       "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-ranlib${HOST_EXECUTABLE_SUFFIX}"   CACHE PATH "ranlib" FORCE)
set(CMAKE_NM           "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-nm${HOST_EXECUTABLE_SUFFIX}"       CACHE PATH "nm" FORCE)
set(CMAKE_OBJCOPY      "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-objcopy${HOST_EXECUTABLE_SUFFIX}"  CACHE PATH "objcopy" FORCE)
set(CMAKE_OBJDUMP      "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-objdump${HOST_EXECUTABLE_SUFFIX}"  CACHE PATH "objdump" FORCE)
set(CMAKE_LINKER       "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-ld${HOST_EXECUTABLE_SUFFIX}"       CACHE PATH "linker" FORCE)
set(CMAKE_STRIP        "${QNX_HOST}/usr/bin/nto${CMAKE_SYSTEM_PROCESSOR}-strip${HOST_EXECUTABLE_SUFFIX}"    CACHE PATH "strip" FORCE)
