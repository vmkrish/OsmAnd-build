cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

# Set the global project name
project("OsmAnd_projects")

set(OSMAND_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")

# Output paths
if(CMAKE_TARGET_BUILD_TOOL STREQUAL "msvs" OR CMAKE_TARGET_BUILD_TOOL STREQUAL "makefile")
	set(OSMAND_OUTPUT_ROOT "${OSMAND_ROOT}/binaries/${CMAKE_TARGET_OS}/${CMAKE_TARGET_CPU_ARCH}/${CMAKE_TARGET_CPU_NAME}/${CMAKE_BUILD_TYPE}")
elseif(CMAKE_TARGET_BUILD_TOOL STREQUAL "xcode")
	set(OSMAND_OUTPUT_ROOT "${OSMAND_ROOT}/binaries/${CMAKE_TARGET_OS}$(EFFECTIVE_PLATFORM_NAME)")
endif()
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${OSMAND_OUTPUT_ROOT}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${OSMAND_OUTPUT_ROOT}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${OSMAND_OUTPUT_ROOT}")

# Enable languages
enable_language(C)
enable_language(CXX)
enable_language(ASM OPTIONAL)

# Apply compiler flags
if(DEFINED CMAKE_COMPILER_ASM_FLAGS)
	set(CMAKE_ASM_FLAGS ${CMAKE_COMPILER_ASM_FLAGS})
endif()
if(DEFINED CMAKE_COMPILER_C_FLAGS)
	set(CMAKE_C_FLAGS ${CMAKE_COMPILER_C_FLAGS})
endif()
if(DEFINED CMAKE_COMPILER_CXX_FLAGS)
	set(CMAKE_CXX_FLAGS ${CMAKE_COMPILER_CXX_FLAGS})
endif()

# For gcc family, ensure that there are no undefined symbols
if(CMAKE_COMPILER_FAMILY STREQUAL "gcc")
	set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--no-undefined")
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-undefined")
endif()

# For gcc and clang, allow all warnings and use proper optimization
if(CMAKE_COMPILER_FAMILY STREQUAL "gcc" OR CMAKE_COMPILER_FAMILY STREQUAL "clang")
	set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Wall -fPIC")
	set(CMAKE_ASM_FLAGS_DEBUG "-O0 -g")
	set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "-O3 -g")
	set(CMAKE_ASM_FLAGS_RELEASE "-O3")

	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -fPIC")
	set(CMAKE_C_FLAGS_DEBUG "-O0 -g")
	set(CMAKE_C_FLAGS_RELWITHDEBINFO "-O3 -g")
	set(CMAKE_C_FLAGS_RELEASE "-O3")

	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -fPIC")
	set(CMAKE_CXX_FLAGS_DEBUG "-O0 -g")
	set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "-O3 -g")
	set(CMAKE_CXX_FLAGS_RELEASE "-O3")
endif()

# For MSVC compiler, allow Level3 warnings (except disabled-by-default and Level4, since too noisy)
if(CMAKE_COMPILER_FAMILY STREQUAL "msvc")
	set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} /W3")
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /W3")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W3")
endif()

# Tune MSVC compiler
if(CMAKE_COMPILER_FAMILY STREQUAL "msvc")
	add_definitions(-DUNICODE -D_UNICODE -D_VARIADIC_MAX=10 -D__STDC_FORMAT_MACROS)
	include_directories(AFTER SYSTEM
		"${OSMAND_ROOT}/core/externals/msinttypes"
	)
endif()

# Add definitions to mark built type
set(CMAKE_ASM_FLAGS_DEBUG "${CMAKE_ASM_FLAGS_DEBUG} -DDEBUG -D_DEBUG")
set(CMAKE_ASM_FLAGS_RELWITHDEBINFO "${CMAKE_ASM_FLAGS_RELWITHDEBINFO} -DRELEASE -DNDEBUG")
set(CMAKE_ASM_FLAGS_RELEASE "${CMAKE_ASM_FLAGS_RELEASE} -DRELEASE -DNDEBUG")

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -DDEBUG -D_DEBUG")
set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} -DRELEASE -DNDEBUG")
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -DRELEASE -DNDEBUG")

set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -D_DEBUG")
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} -DRELEASE -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -DRELEASE -DNDEBUG")

# Include CPU specific settings
if(DEFINED CMAKE_TARGET_CPU_NAME)
	include("cpu-specific/${CMAKE_TARGET_CPU_NAME}.cmake")
endif()

# Expose target environment to code
add_definitions(
	-DOSMAND_TARGET_OS_${CMAKE_TARGET_OS}
	-DOSMAND_TARGET_CPU_ARCH_${CMAKE_TARGET_CPU_ARCH}
	-DOSMAND_TARGET_CPU_ARCH_FAMILY_${CMAKE_TARGET_CPU_ARCH_FAMILY}
	-DOSMAND_COMPILER_FAMILY_${CMAKE_COMPILER_FAMILY}
)

# Target specific changes
if(CMAKE_TARGET_OS STREQUAL "linux")
elseif(CMAKE_TARGET_OS STREQUAL "darwin")
elseif(CMAKE_TARGET_OS STREQUAL "windows")
elseif(CMAKE_TARGET_OS STREQUAL "qnx")
	include_directories(AFTER
		${QNX_TARGET}/usr/include/freetype2
	)
endif()

# Don't define min and max macros
add_definitions(-DNOMINMAX)

# Qt selection: external, system or embedded
if(DEFINED ENV{OSMAND_EXTERNAL_QT})
	# External
	set(OSMAND_EXTERNAL_QT ON)
	message("Using external Qt5: $ENV{OSMAND_EXTERNAL_QT}")
	list(APPEND CMAKE_PREFIX_PATH "$ENV{OSMAND_EXTERNAL_QT}/lib/cmake")
elseif(DEFINED ENV{OSMAND_SYSTEM_QT})
	# System
	set(OSMAND_SYSTEM_QT ON)
	message("Using system Qt5.")
else()
	# Embedded: shared and static
	set(OSMAND_EMBEDDED_QT ON)

	# Flavour: desktop, iOS or etc.
	if(CMAKE_TARGET_OS STREQUAL "linux" OR CMAKE_TARGET_OS STREQUAL "darwin" OR CMAKE_TARGET_OS STREQUAL "windows")
		set(OSMAND_QT_FLAVOUR "desktop")
	elseif(CMAKE_TARGET_OS STREQUAL "ios")
		set(OSMAND_QT_FLAVOUR "ios")
	else()
		message(FATAL_ERROR "Failed to determine Qt flavour")
	endif()

	# If shared libs are allowed, they need shared Qt
	if(CMAKE_SHARED_LIBS_ALLOWED_ON_TARGET)
		if(EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_TARGET_CPU_ARCH}.shared/lib/cmake")
			set(OSMAND_EMBEDDED_QT_SHARED "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_TARGET_CPU_ARCH}.shared")
		elseif(EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.shared/lib/cmake")
			set(OSMAND_EMBEDDED_QT_SHARED "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.shared")
		endif()

		if(NOT DEFINED OSMAND_EMBEDDED_QT_SHARED)
			message(FATAL_ERROR "Embedded shared Qt not found")
		else()
			message("Using embedded Qt5 (shared): ${OSMAND_EMBEDDED_QT_SHARED}")
		endif()
	endif()

	# If static libs are allowed, they need static Qt
	if(CMAKE_STATIC_LIBS_ALLOWED_ON_TARGET)
		if(EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_TARGET_CPU_ARCH}.static/lib/cmake")
			set(OSMAND_EMBEDDED_QT_STATIC "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.${CMAKE_TARGET_CPU_ARCH}.static")
		elseif(EXISTS "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.static/lib/cmake")
			set(OSMAND_EMBEDDED_QT_STATIC "${OSMAND_ROOT}/core/externals/qtbase-${OSMAND_QT_FLAVOUR}/upstream.patched.${CMAKE_TARGET_OS}.static")
		endif()

		if(NOT DEFINED OSMAND_EMBEDDED_QT_STATIC)
			message(FATAL_ERROR "Embedded static Qt not found")
		else()
			message("Using embedded Qt5 (static): ${OSMAND_EMBEDDED_QT_STATIC}")
		endif()
	endif()
endif()

# Core
if(EXISTS "${OSMAND_ROOT}/core")
	include("${OSMAND_ROOT}/core/core.cmake")
endif()

# Tools are only valid on desktop platforms
if(CMAKE_TARGET_OS STREQUAL "linux" OR CMAKE_TARGET_OS STREQUAL "darwin" OR CMAKE_TARGET_OS STREQUAL "windows")
	if(EXISTS "${OSMAND_ROOT}/tools")
		include("${OSMAND_ROOT}/tools/tools.cmake")
	endif()
endif()
