// Copyright 2026 elkuno213
//
// Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
// or at https://opensource.org/licenses/MIT.

#pragma once

#include <string>
#include <rclcpp/rclcpp.hpp>
#include <sensor_msgs/msg/temperature.hpp>

namespace example_cpp_pubsub {

class TemperaturePublisherNode final : public rclcpp::Node {
public:
  explicit TemperaturePublisherNode(const rclcpp::NodeOptions& options = rclcpp::NodeOptions());

private:
  void publishSample();

  rclcpp::Publisher<sensor_msgs::msg::Temperature>::SharedPtr _publisher;
  rclcpp::TimerBase::SharedPtr                                _timer;
  double                                                      _temperature_celsius{21.5};
  std::string                                                 _frame_id{"base_link"};
};

}  // namespace example_cpp_pubsub
