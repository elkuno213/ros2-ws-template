"""ROS2 subscriber node for formatted temperature reports."""

from __future__ import annotations

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Temperature

from example_py_tools.temperature_format import TemperatureReading, format_temperature


class TemperatureReporterNode(Node):
    """Report temperature messages published by the C++ example package."""

    def __init__(self) -> None:
        """Create the ROS2 subscription and keep it alive for the node lifetime."""
        super().__init__("temperature_reporter")
        self._subscription = self.create_subscription(
            Temperature,
            "example/temperature",
            self._on_temperature,
            10,
        )

    def _on_temperature(self, message: Temperature) -> None:
        """Convert a ROS temperature message to the core model and log it."""
        reading = TemperatureReading(
            frame_id=message.header.frame_id,
            celsius=float(message.temperature),
        )
        self.get_logger().info(format_temperature(reading))


def run_temperature_reporter(args: list[str] | None = None) -> None:
    """Run the temperature reporter node until shutdown."""
    rclpy.init(args=args)
    node = TemperatureReporterNode()
    try:
        rclpy.spin(node)
    finally:
        node.destroy_node()
        rclpy.shutdown()


if __name__ == "__main__":
    run_temperature_reporter()
