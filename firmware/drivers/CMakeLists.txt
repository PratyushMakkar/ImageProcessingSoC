cmake_minimum_required(VERSION 3.15)

target_include_directories(ImageProcSOC PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/timer
  ${CMAKE_CURRENT_SOURCE_DIR}/gpio
)

target_sources(ImageProcSOC PUBLIC
  ${CMAKE_CURRENT_SOURCE_DIR}/timer/timer.c
)