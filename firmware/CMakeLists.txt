cmake_minimum_required(VERSION 3.15)

project(ImageProcSOC)

add_executable(ImageProcSOC main.c)
target_include_directories(ImageProcSOC PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/common
)

add_subdirectory(drivers)