cmake_minimum_required(VERSION 3.15)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER "arm-none-eabi-gcc.exe")

project(ImageProcSOC)

add_executable(ImageProcSOC main.c)
target_include_directories(ImageProcSOC PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/common
)

add_subdirectory(drivers)