// Copyright 2026 elkuno213
//
// Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
// or at https://opensource.org/licenses/MIT.

#pragma once

#include <string>

namespace example_cpp_pubsub {

struct TemperatureSample {
  double      celsius{0.0};
  std::string frame_id{"base_link"};
};

[[nodiscard]] std::string formatTemperatureCelsius(const TemperatureSample& sample);

}  // namespace example_cpp_pubsub
