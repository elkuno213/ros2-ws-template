// Copyright 2026 elkuno213
//
// Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
// or at https://opensource.org/licenses/MIT.

#include <gtest/gtest.h>
#include "example_cpp_pubsub/temperature_sample.hpp"

namespace example_cpp_pubsub {

TEST(TemperatureSampleTest, FormatsTemperatureWithFrameId) {
  const TemperatureSample sample{
    .celsius  = 21.5,
    .frame_id = "base_link",
  };

  EXPECT_EQ(formatTemperatureCelsius(sample), "base_link: 21.50 C");
}

TEST(TemperatureSampleTest, FormatsNegativeTemperatureWithTwoDecimals) {
  const TemperatureSample sample{
    .celsius  = -2.125,
    .frame_id = "sensor",
  };

  EXPECT_EQ(formatTemperatureCelsius(sample), "sensor: -2.12 C");
}

}  // namespace example_cpp_pubsub
