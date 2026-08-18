# Copyright 2026 elkuno213
#
# Use of this source code is governed by an MIT-style license that can be found in the
# LICENSE file or at https://opensource.org/licenses/MIT.

"""Launch the example C++ temperature publisher."""

from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description() -> LaunchDescription:
    """Create the launch description for the C++ publisher node."""
    return LaunchDescription(
        [
            Node(
                package="example_cpp_pubsub",
                executable="temperature_publisher",
                name="temperature_publisher",
                output="screen",
            ),
        ],
    )
