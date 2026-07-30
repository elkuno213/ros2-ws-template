"""Executable entrypoint for the Python temperature reporter."""

from example_py_tools.temperature_reporter_node import run_temperature_reporter


def main(args: list[str] | None = None) -> None:
    """Run the Python temperature reporter node."""
    run_temperature_reporter(args=args)


if __name__ == "__main__":
    main()
