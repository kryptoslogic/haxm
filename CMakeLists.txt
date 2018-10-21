cmake_minimum_required(VERSION 2.8)
project(haxm C)

# Configuration
enable_language(ASM_NASM)

# Platforms
option(PLATFORM_DARWIN   "Build for MacOS systems")
option(PLATFORM_LINUX    "Build for Linux systems")
option(PLATFORM_WINDOWS  "Build for Windows systems")

# Platform auto-select
if (NOT (PLATFORM_DARWIN OR PLATFORM_LINUX OR PLATFORM_WINDOWS))
    message(STATUS "No target system specified (-DTARGET_*=ON). Choosing platform automatically...")
    if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        message(STATUS "Using PLATFORM_DARWIN.")
        set(PLATFORM_DARWIN ON)
    elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
        message(STATUS "Using PLATFORM_LINUX.")
        set(PLATFORM_LINUX ON)
    elseif (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
        message(STATUS "Using PLATFORM_WINDOWS.")
        set(PLATFORM_WINDOWS ON)
    endif()
endif()

# Paths
set(HAX_PATH_ROOT      "${CMAKE_CURRENT_LIST_DIR}")
set(HAX_PATH_CMAKE     "${HAX_PATH_ROOT}/cmake/")
set(HAX_PATH_CORE      "${HAX_PATH_ROOT}/core/")
set(HAX_PATH_TESTS     "${HAX_PATH_ROOT}/tests/")

if (PLATFORM_DARWIN)
    set(HAX_PATH_PLATFORM  "${HAX_PATH_ROOT}/darwin/hax_driver/com_intel_hax/")
elseif (PLATFORM_LINUX)
    set(HAX_PATH_PLATFORM  "${HAX_PATH_ROOT}/linux/")
elseif (PLATFORM_WINDOWS)
    set(HAX_PATH_PLATFORM  "${HAX_PATH_ROOT}/windows/")
endif()

# Sources
file(GLOB_RECURSE HAX_FILES_CORE_ASM
    ${HAX_PATH_CORE}/*.asm)
file(GLOB_RECURSE HAX_FILES_CORE_C
    ${HAX_PATH_CORE}/*.c)
set(HAX_FILES_CORE
    ${HAX_FILES_CORE_ASM}
    ${HAX_FILES_CORE_C})

# Modules
list(APPEND CMAKE_MODULE_PATH ${HAX_PATH_CMAKE})

# Project: HAXM-Platform
if (PLATFORM_DARWIN)
endif()

if (PLATFORM_LINUX)
endif()

if (PLATFORM_WINDOWS)
    find_package(WDK REQUIRED)
    find_package(MC REQUIRED)

    file(GLOB_RECURSE HAX_FILES_PLATFORM_C
        ${HAX_PATH_PLATFORM}/*.c)
    file(GLOB_RECURSE HAX_FILES_PLATFORM_MC
        ${HAX_PATH_PLATFORM}/*.mc)
    set(HAX_FILES_PLATFORM
        ${HAX_FILES_PLATFORM_C}
        ${HAX_FILES_PLATFORM_MC})

    # Message Compiler
    set_source_files_properties(
        ${HAX_PATH_PLATFORM}/hax_event_win.h
        PROPERTIES GENERATED true)
    add_custom_command(
        OUTPUT  ${HAX_PATH_PLATFORM}/hax_event_win.h
        DEPENDS ${HAX_PATH_PLATFORM}/hax_event_win.mc
        COMMAND ${CMAKE_MC_COMPILER}
        ARGS -h ${HAX_PATH_PLATFORM}
             -r ${HAX_PATH_PLATFORM}
                ${HAX_PATH_PLATFORM}/hax_event_win.mc
        VERBATIM)

    wdk_add_library(haxm STATIC
        ${HAX_FILES_CORE})
    wdk_add_driver(haxm-driver
        ${HAX_FILES_PLATFORM}
        ${HAX_PATH_PLATFORM}/hax_event_win.h)

    target_link_libraries(haxm-driver haxm)
    target_link_libraries(haxm-driver WDK::BUFFEROVERFLOWK)
    target_link_libraries(haxm-driver WDK::HAL)
    target_link_libraries(haxm-driver WDK::NTOSKRNL)
    target_link_libraries(haxm-driver WDK::WMILIB)
    target_link_libraries(haxm-driver WDK::WDMSEC)
endif()

# Includes
target_include_directories(haxm PUBLIC
    ${HAX_PATH_ROOT}/include)
target_include_directories(haxm PRIVATE
    ${HAX_PATH_CORE}/include)

target_include_directories(haxm-driver PUBLIC
    ${HAX_PATH_ROOT}/include)
target_include_directories(haxm-driver PRIVATE
    ${HAX_PATH_CORE}/include)
target_include_directories(haxm-driver PRIVATE
    ${HAX_PATH_ROOT}/include/windows)
target_include_directories(haxm-driver PRIVATE
    ${HAX_PATH_PLATFORM})

# Tests
#TODO
