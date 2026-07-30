// Copyright 2026 elkuno213
//
// Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
// or at https://opensource.org/licenses/MIT.

#include "example_cpp_pubsub/temperature_sample.hpp"
#include <iomanip>
#include <sstream>
#include <string>

namespace example_cpp_pubsub {

std::string formatTemperatureCelsius(const TemperatureSample& sample) {
  std::ostringstream stream;
  stream << sample.frame_id << ": " << std::fixed << std::setprecision(2) << sample.celsius << " C";
  return stream.str();
}

}  // namespace example_cpp_pubsub
