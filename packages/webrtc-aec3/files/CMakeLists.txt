cmake_minimum_required(VERSION 3.10)
project(webrtc_aec3 CXX C)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -include stddef.h")

add_definitions(-DWEBRTC_POSIX -DWEBRTC_LINUX)
add_definitions(-DWEBRTC_POSIX -DWEBRTC_LINUX -DWEBRTC_HAS_NEON)
add_compile_options(-O2 -Wno-deprecated-declarations)

file(GLOB_RECURSE AEC3_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/api/*.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/api/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/audio_processing/*.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/audio_processing/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/base/rtc_base/*.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/base/rtc_base/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/base/system_wrappers/source/*.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/base/system_wrappers/source/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/base/jsoncpp/src/lib_json/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/base/abseil/absl/*.cc
)

# Исключаем тесты, бенчмарки, утилиты Abseil со своим main() и x86/ARM64 SIMD
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*/demo/.*")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_test\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_unittest\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*testing.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*test_helpers.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*/abseil/.*test.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*benchmark.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*fuzz.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*mock.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*pffft_wrapper\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*mutex_nonprod\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*print_hash_of\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*gentables\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*sequence_generator.*\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*chi_square\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_sse\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_sse2\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_avx2\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_mips\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_mips\\.c$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_win\\.cc$")
list(FILTER AEC3_SOURCES EXCLUDE REGEX ".*_mac\\.cc$")

add_executable(aec3_cmdline
    ${CMAKE_CURRENT_SOURCE_DIR}/aec3_cmdline.cc
    ${AEC3_SOURCES}
)

add_compile_options(-O2 -Wno-deprecated-declarations -include cstdlib)

target_include_directories(aec3_cmdline PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/base/abseil
    ${CMAKE_CURRENT_SOURCE_DIR}/base/jsoncpp/include
    ${CMAKE_CURRENT_SOURCE_DIR}/base/system_wrappers/include
    ${CMAKE_CURRENT_SOURCE_DIR}/audio_processing
)

target_link_libraries(aec3_cmdline PRIVATE -static-libstdc++ -static-libgcc pthread)