# ROS2 Development Environment with Docker and VSCode Remote Explorer

This repository sets up a Docker-based development environment for ROS2 (Humble), enabling you to code, build, and debug ROS2 projects using VSCode Remote Explorer. It includes a multi-container setup with a noVNC GUI container to forward the graphical output from the ROS2 container.

## Features

- Dockerized ROS2 Humble Environment based on [osrf/ros:humble-desktop-full](https://hub.docker.com/layers/osrf/ros/humble-desktop-full/images/sha256-71ae08a6a0aae71a2f981e066c8a1d7dd76e956abf419c04626a0c746c3ebf4f).
- Pre-configured VSCode Integration: C++/Python linting, shell, and debugging configurations for ROS2 development.
- Multi-Container Setup:
  - `ros2` container: Primary container for development.
  - `ros2-novnc` container: Provides GUI forwarding using noVNC.

## Getting Started

### Prerequisites

1. Install Docker.
2. Install VSCode.
3. Install the VSCode Remote Explorer extension.

### Repository Structure

```bash
.
├── README.md
├── Dockerfile                # Dockerfile for `ros2` container
├── compose.yaml              # Multi-container setup
├── .clang-format
├── .gitignore
└── .vscode
    ├── c_cpp_properties.json
    ├── extensions.json
    ├── launch.json
    ├── settings.json
    └── tasks.json
```

### Setting Up the Environment

1. Clone this reposity:

```bash
git clone https://github.com/elkuno213/ros2-ws-template.git
cd ros2-ws-template
```

2. Build and launch the containers:

```bash
env USERNAME=nonroot UID=$(id -u) GID=$(id -g) docker compose up -d
```

- `USERNAME`: Non-root username inside the container.
- `UID`/`GID`: Ensures correct file permissions between the host and container.

3. Open VSCode and connect to the `ros2` container using the Remote Explorer extension.

### Accessing the GUI

The `ros2-novnc` container provides GUI access via noVNC. Access it in your browser at http://localhost:8080.

## VSCode Configuration

- `settings.json`: ROS2-related settings for CMake, Clang-Format, Python, and more.
- `c_cpp_properties.json`: Configures C++ linting with ms-vscode.cpptools.
- `tasks.json`: Predefined build commands using colcon.
- `launch.json`: Debug configurations for:
  - ROS2 C++ node.
  - ROS2 Python node.
  - ROS2 Launch of multiple nodes.
  - ROS2 Python launch file.

## Development Workflow

1. Open the project folder in VSCode.
2. Connect to the `ros2` container via the Remote Explorer extension.
3. Go to `/workspaces/ros2` and build your packages by commands or tasks.
4. If debugging, use the corresponding configuration in `.vscode/launch.json`.


## FAQ

### How to debug Python launch file?

Create a temporary file `<launch-file>.debug.py` alongside the origin to debug:

```python
from .<launch-file> import generate_launch_description
from launch import LaunchService


def main():
  ls = LaunchService()
  ld = generate_launch_description()
  ls.include_launch_description(ld)
  return ls.run()


if __name__ == '__main__':
  main()
```

## Contribution

If you have any questions, suggestions, or encounter any issues, feel free to create an issue in the repository. I welcome your feedback and contributions to improve this project!
