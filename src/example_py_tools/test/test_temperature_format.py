"""Tests for pure temperature formatting logic."""

import pytest

from example_py_tools.temperature_format import TemperatureReading, format_temperature


@pytest.mark.parametrize(
    ("reading", "formatted"),
    [
        (TemperatureReading(frame_id="base_link", celsius=21.5), "base_link: 21.50 C"),
        (TemperatureReading(frame_id="sensor", celsius=-2.125), "sensor: -2.12 C"),
    ],
)
def test_format_temperature_includes_frame_and_value(
    reading: TemperatureReading,
    formatted: str,
) -> None:
    """Format readings with frame id and two decimal places."""
    assert format_temperature(reading) == formatted
