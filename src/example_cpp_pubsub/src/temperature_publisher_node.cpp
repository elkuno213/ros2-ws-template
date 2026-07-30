// Copyright 2026 elkuno213
//
// Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
// or at https://opensource.org/licenses/MIT.

#include "example_cpp_pubsub/temperature_publisher_node.hpp"
#include <chrono>
#include <string>
#include "example_cpp_pubsub/temperature_sample.hpp"

namespace example_cpp_pubsub {
namespace {

constexpr auto kTopicName     = "example/temperature";
constexpr auto kQueueDepth    = 10;
constexpr auto kPublishPeriod = std::chrono::milliseconds{500};

}  // namespace

TemperaturePublisherNode::TemperaturePublisherNode(const rclcpp::NodeOptions& options)
  : rclcpp::Node("temperature_publisher", options) {
  _temperature_celsius = declare_parameter<double>("temperature_celsius", _temperature_celsius);
  _frame_id            = declare_parameter<std::string>("frame_id", _frame_id);

  auto publish_callback = [this]() {
    publishSample();
  };

  _publisher = create_publisher<sensor_msgs::msg::Temperature>(kTopicName, kQueueDepth);
  _timer     = create_wall_timer(kPublishPeriod, publish_callback);
}

// ROS logging macros expand into nested control flow for clang-tidy.
// NOLINTNEXTLINE
void TemperaturePublisherNode::publishSample() {
  sensor_msgs::msg::Temperature message;
  message.header.stamp    = get_clock()->now();
  message.header.frame_id = _frame_id;
  message.temperature     = _temperature_celsius;
  message.variance        = 0.0;

  _publisher->publish(message);

  const TemperatureSample sample{
    .celsius  = _temperature_celsius,
    .frame_id = _frame_id,
  };
  const auto formatted_sample = formatTemperatureCelsius(sample);

  RCLCPP_INFO_THROTTLE(get_logger(), *get_clock(), 2000, "published %s", formatted_sample.c_str());
}

}  // namespace example_cpp_pubsub
