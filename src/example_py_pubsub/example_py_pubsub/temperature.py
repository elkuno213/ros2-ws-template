"""Temperature formatting helpers for the example package."""

from dataclasses import dataclass


@dataclass(frozen=True)
class TemperatureReading:
    """Temperature reading detached from ROS message types."""

    frame_id: str
    celsius: float


def format_temperature(reading: TemperatureReading) -> str:
    """Format a temperature reading for logs and tests."""
    return f"{reading.frame_id}: {reading.celsius:.2f} C"
