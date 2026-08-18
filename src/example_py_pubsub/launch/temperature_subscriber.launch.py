# Copyright 2026 elkuno213
#
# Use of this source code is governed by an MIT-style license that can be found in the
# LICENSE file or at https://opensource.org/licenses/MIT.

"""Launch the example Python temperature subscriber."""

from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description() -> LaunchDescription:
    """Create the launch description for the Python subscriber node."""
    return LaunchDescription(
        [
            Node(
                package="example_py_pubsub",
                executable="temperature_subscriber",
                name="temperature_subscriber",
                output="screen",
            ),
        ],
    )
