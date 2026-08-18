# Copyright 2026 elkuno213
#
# Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
# or at https://opensource.org/licenses/MIT.

cmake_minimum_required(VERSION 3.8)
project(example_cpp_pubsub)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic -Werror)
endif()

find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)

add_library(example_cpp_pubsub_core src/temperature_sample.cpp)
target_compile_features(example_cpp_pubsub_core PUBLIC cxx_std_20)
target_include_directories(
  example_cpp_pubsub_core
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

add_library(example_cpp_pubsub_node src/temperature_publisher_node.cpp)
target_compile_features(example_cpp_pubsub_node PUBLIC cxx_std_20)
target_include_directories(
  example_cpp_pubsub_node
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
target_link_libraries(example_cpp_pubsub_node example_cpp_pubsub_core)
ament_target_dependencies(example_cpp_pubsub_node rclcpp sensor_msgs)

add_executable(temperature_publisher src/temperature_publisher_main.cpp)
target_compile_features(temperature_publisher PUBLIC cxx_std_20)
target_link_libraries(temperature_publisher example_cpp_pubsub_node)
ament_target_dependencies(temperature_publisher rclcpp)

install(
  TARGETS
    example_cpp_pubsub_core
    example_cpp_pubsub_node
    temperature_publisher
  EXPORT export_${PROJECT_NAME}
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION lib/${PROJECT_NAME}
)

install(DIRECTORY include/ DESTINATION include)
install(DIRECTORY launch DESTINATION share/${PROJECT_NAME})

if(BUILD_TESTING)
  find_package(ament_cmake_gtest REQUIRED)
  find_package(ament_lint_auto REQUIRED)
  set(ament_cmake_clang_tidy_CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../.clang-tidy)
  set(ament_cmake_uncrustify_ADDITIONAL_ARGS
      CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/uncrustify.cfg
  )
  set(ament_cmake_cppcheck_FOUND TRUE)
  ament_lint_auto_find_test_dependencies()

  ament_add_gtest(test_temperature_sample test/test_temperature_sample.cpp)
  target_link_libraries(test_temperature_sample example_cpp_pubsub_core)
endif()

ament_export_targets(export_${PROJECT_NAME} HAS_LIBRARY_TARGET)
ament_export_dependencies(rclcpp sensor_msgs)
ament_package()
