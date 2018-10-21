# Redistribution and use is allowed under the OSI-approved 3-clause BSD license.
# Copyright (c) 2018 Kryptos Logic LLC. All rights reserved.

#.rst:
# FindMC
# ------
#
# This module searches for the installed Message Compiler (MC) in the
# Windows SDK/Kits and exposes it to create manifests and message text files.
#
# Output variables:
# - `MC_FOUND` -- if false, do not try to use MC
#

if ("${CMAKE_GENERATOR}" MATCHES "Visual Studio")
    get_filename_component(WIN_SDK_DIR   "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Microsoft SDKs\\Windows;CurrentInstallFolder]" REALPATH)
    get_filename_component(WIN_KIT_DIR   "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot]" REALPATH)
    get_filename_component(WIN_KIT81_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot81]" REALPATH)
    get_filename_component(WIN_KIT10_DIR "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows Kits\\Installed Roots;KitsRoot10]" REALPATH)

    if (X64)
        set(MC_HINTS
            "${WIN_SDK_DIR}/bin/x64"
            "${WIN_KIT_DIR}/bin/x64"
            "${WIN_KIT81_DIR}/bin/x64"
            "${WIN_KIT10_DIR}/bin/x64")
    else()
        set(MC_HINTS
            "${WIN_SDK_DIR}/bin"
            "${WIN_KIT_DIR}/bin/x86"
            "${WIN_KIT81_DIR}/bin/x86"
            "${WIN_KIT10_DIR}/bin/x86")
    endif()
endif()

find_program(CMAKE_MC_COMPILER mc.exe HINTS ${MC_HINTS}
    DOC "Path to Message Compiler (mc.exe)")
if (NOT CMAKE_MC_COMPILER)
    message(FATAL_ERROR "Message Compiler (mc.exe) not found")
    set (MC_FOUND FALSE)
endif()

set (MC_FOUND TRUE)
message(STATUS "Found Message Compiler: ${CMAKE_MC_COMPILER}")
mark_as_advanced(CMAKE_MC_COMPILER)
