# ROS2 Workspace Template

Compose-first ROS2 Humble workspace for C++ and Python robotics development. The
template is built around a Docker Compose container, VS Code attach workflow,
browser GUI access through noVNC, and repeatable `colcon` validation.

## Contents

- ROS2 Humble desktop development image.
- Stable container workspace path: `/workspaces/ros2-ws`.
- VS Code attach workflow, with optional Dev Containers wrapper.
- noVNC browser access for GUI tools.
- C++ `rclcpp` example package with GoogleTest and clang-tidy checks.
- Python `rclpy` example package with a flat structure, pytest, and Ruff checks.
- clangd, clang-format, clang-tidy, Ruff, uv, and VS Code task
  configuration.
- GitHub Actions smoke workflow for image build, rosdep, colcon build, and tests.

## Prerequisites

- Docker with Docker Compose v2.
- VS Code.
- VS Code Remote Development or Dev Containers extension.

## Quickstart

```bash
git clone https://github.com/elkuno213/ros2-ws-template.git
cd ros2-ws-template
docker compose up -d --build --remove-orphans
```

Open a shell in the ROS2 container:

```bash
docker compose exec ros2 zsh -l
```

Build and test inside the container:

```bash
cd /workspaces/ros2-ws
source /opt/ros/humble/setup.zsh
rosdep update
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -GNinja
colcon test
colcon test-result --all --verbose
```

## VS Code Workflow

Primary workflow:

1. Start the stack with `docker compose up -d --build --remove-orphans`.
2. Open this repository in VS Code.
3. Run **Dev Containers: Attach to Running Container**.
4. Select the `ros2` container.
5. Open `/workspaces/ros2-ws` as the workspace folder inside the container.

`.devcontainer/devcontainer.json` is only a convenience wrapper over
`compose.yaml`. Keep Compose as the runtime source of truth.

## VS Code Debugging

The tracked VS Code tasks and launch configs are intended to run after attaching
VS Code to the `ros2` container.

For C++ nodes, run the `colcon-build-debug` task, enter the package name, update
the `<pkg-name>/<node-name>` placeholders in the `(gdb) ROS2 C++ Node` launch
configuration, then start the debugger.

For Python nodes, open the node file and start the `ROS2 Python Node` launch
configuration. The `source-ws` task writes `.env` from the sourced ROS2
environment before the debugger starts.

For ROS2 launch files, open the launch file and use the `ROS2 Launch (Current
File)` launch configuration from the VS Code ROS extension.

## GUI Access

noVNC is exposed on host port `8080` by default:

```text
http://localhost:8080/vnc.html
```

The ROS2 container uses:

```text
DISPLAY=ros2-novnc:0.0
```

Use RViz or other GUI tools from inside the `ros2` container after the stack is
running.

To choose a different host port, set `NOVNC_PORT`:

```bash
NOVNC_PORT=6080 docker compose up -d --build --remove-orphans
```

## Optional Camera Devices

`compose.devices.yaml` is not required for the current example packages. It is
an optional override for machines that have local camera devices and need to pass
them into the ROS2 container.

Use it only when `/dev/video0` and `/dev/video1` exist:

```bash
docker compose -f compose.yaml -f compose.devices.yaml up -d --remove-orphans
```

The default `compose.yaml` intentionally avoids device mounts so clean clones work
on machines without cameras.

## Example Packages

### `example_cpp_pubsub`

C++ package:

- publishes `sensor_msgs/msg/Temperature` on `example/temperature`;
- keeps formatting logic in a small pure C++ function;
- tests pure logic with GoogleTest;
- runs ament lint checks including clang-tidy.

Run after build:

```bash
source install/setup.zsh
ros2 run example_cpp_pubsub temperature_publisher
```

### `example_py_pubsub`

Python package:

- keeps the example intentionally flat;
- defines the ROS2 subscriber node and entrypoint in `temperature_subscriber.py`;
- keeps testable formatting helpers in `temperature.py`;
- tests pure formatting with pytest;
- is covered by repository-level Ruff checks.

Run after build:

```bash
source install/setup.zsh
ros2 run example_py_pubsub temperature_subscriber
```

## Tooling

- `.clang-format` defines C++ formatting.
- `.clang-tidy` defines C++ diagnostics and naming checks.
- `.clangd` and VS Code point clangd at `build/compile_commands.json`.
- `pyproject.toml` defines Python Ruff configuration.
- Docker installs Ruff as a uv-managed user tool for the `ros` user.
- `.vscode/tasks.json` provides build, test, and clean tasks for the container
  workspace.

The Docker image installs `uv`, then uses `uv tool install` to make `ruff`
available on `PATH`. The workspace does not need a project `.venv` for tooling.

Generate compile commands before relying on clangd diagnostics:

```bash
colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -GNinja
ln -sf example_cpp_pubsub/compile_commands.json build/compile_commands.json
```

Expected compile database:

```text
build/compile_commands.json
```

## Troubleshooting

### noVNC is not reachable

Check the service:

```bash
docker compose ps ros2-novnc
```

Open:

```text
http://localhost:8080/vnc.html
```

### Camera device mount fails

Start without the optional override:

```bash
docker compose up -d --remove-orphans
```

Use `compose.devices.yaml` only on hosts where the listed `/dev/video*` devices
exist.

### Python tools are missing

Confirm the tools are available inside the `ros2` container:

```bash
uv --version
ruff --version
```

If `ruff` is missing, rebuild and recreate the ROS2 service:

```bash
docker compose up -d --build --remove-orphans
```

### clangd cannot find compile commands

Build once inside the container:

```bash
colcon build --symlink-install --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -GNinja
ln -sf example_cpp_pubsub/compile_commands.json build/compile_commands.json
```

Then confirm:

```bash
test -f build/compile_commands.json
```

## Future Work

- TODO: Investigate the `Ranch-Hand-Robotics.rde-pack` VS Code extension for
  future editor setup improvements.

## Limitations

- No Jetson, CUDA, or simulation image variant.
- noVNC is for development convenience, not production GUI serving.
- Example packages demonstrate workflow and structure, not robotics algorithms.
