cmake_minimum_required(VERSION 3.10)
project(Prometheus LANGUAGES CXX OBJCXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD 17)

# Find necessary frameworks
find_library(APPKIT_LIBRARY AppKit)
find_library(CORE_GRAPHICS_LIBRARY CoreGraphics)
find_library(FOUNDATION_LIBRARY Foundation)

# Find CURL
find_package(CURL REQUIRED)

add_executable(Prometheus src/main.mm src/GeminiAPI.cpp src/base64.cpp)

# Link against the AppKit and CoreGraphics frameworks
target_link_libraries(Prometheus PRIVATE ${APPKIT_LIBRARY} ${CORE_GRAPHICS_LIBRARY} ${FOUNDATION_LIBRARY} ${CURL_LIBRARIES})
target_include_directories(Prometheus PRIVATE ${CURL_INCLUDE_DIRS})
