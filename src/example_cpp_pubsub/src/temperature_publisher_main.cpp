// Copyright 2026 elkuno213
//
// Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
// or at https://opensource.org/licenses/MIT.

#include <memory>
#include <rclcpp/rclcpp.hpp>
#include "example_cpp_pubsub/temperature_publisher_node.hpp"

int main(int argc, char** argv) {
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<example_cpp_pubsub::TemperaturePublisherNode>());
  rclcpp::shutdown();
  return 0;
}
