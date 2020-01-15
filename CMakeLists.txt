cmake_minimum_required(VERSION 3.10)
project(proxychainsng C)

set(lib_name proxychains4)

include_directories(${PROJECT_SOURCE_DIR}/src)

add_definitions(-DDLL_NAME="${CMAKE_SHARED_LIBRARY_PREFIX}${lib_name}${CMAKE_SHARED_LIBRARY_SUFFIX}")
add_definitions(-DLIB_DIR="${PROJECT_BINARY_DIR}")
add_definitions(-DSYSCONFDIR="/etc")

if (UNIX AND NOT APPLE)
  add_definitions(-D_GNU_SOURCE)
endif ()

if (CMAKE_BUILD_TYPE EQUAL Debug OR CMAKE_BUILD_TYPE EQUAL debug OR CMAKE_BUILD_TYPE EQUAL DEBUG)
  add_definitions(-DDEBUG)
endif ()

set(version_file ${PROJECT_BINARY_DIR}/version.h)
include_directories(${PROJECT_BINARY_DIR})

add_custom_target(update_version ALL DEPENDS ${version_file})

add_custom_command(
    COMMAND sh ${PROJECT_SOURCE_DIR}/tools/gen_version_file.sh
    OUTPUT ${version_file}
    COMMENT "Bundling ${version_file}"
    VERBATIM)

set(src_files
    ${PROJECT_SOURCE_DIR}/src/allocator_thread.c
    ${PROJECT_SOURCE_DIR}/src/common.c
    ${PROJECT_SOURCE_DIR}/src/core.c
    ${PROJECT_SOURCE_DIR}/src/debug.c
    ${PROJECT_SOURCE_DIR}/src/hash.c
    ${PROJECT_SOURCE_DIR}/src/hostsreader.c
    ${PROJECT_SOURCE_DIR}/src/ip_type.c
    ${PROJECT_SOURCE_DIR}/src/libproxychains.c
    ${PROJECT_SOURCE_DIR}/src/nameinfo.c
    ${PROJECT_SOURCE_DIR}/src/version.c)

add_library(${lib_name} SHARED ${src_files})
target_link_libraries(${lib_name} pthread dl)
add_dependencies(${lib_name} update_version)

add_executable(${PROJECT_NAME} ${PROJECT_SOURCE_DIR}/src/main.c)
target_link_libraries(${PROJECT_NAME} ${lib_name})

function(my_test name)
  set(tname test_${name})
  add_executable(${tname} ${PROJECT_SOURCE_DIR}/tests/${tname}.c)
  target_link_libraries(${tname} ${lib_name})
endfunction()

my_test(getaddrinfo)
my_test(sendto)
my_test(v4_in_v6)
