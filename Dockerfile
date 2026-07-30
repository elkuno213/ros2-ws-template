FROM osrf/ros:humble-desktop-full

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Build arguments keep the image reusable across host users while preserving
# fixed compiler versions for repeatable local tooling behavior.
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=${USER_UID}
ARG LLVM_VERSION=22
ARG GCC_VERSION=13

# ROS logs stay readable in compose exec shells and CI logs.
ENV DEBIAN_FRONTEND=noninteractive
ENV RCUTILS_COLORIZED_OUTPUT=1

# Base development tools shared by C++, Python, ROS2, and editor workflows.
RUN apt-get update                                                                                 \
    && apt-get install --no-install-recommends -y                                                  \
        ca-certificates                                                                            \
        curl                                                                                       \
        gdb                                                                                        \
        gdbserver                                                                                  \
        git                                                                                        \
        gosu                                                                                       \
        gnupg                                                                                      \
        lsb-release                                                                                \
        ninja-build                                                                                \
        python3-argcomplete                                                                        \
        python3-pip                                                                                \
        python3-pytest                                                                             \
        ros-humble-ament-cmake-clang-tidy                                                          \
        rsync                                                                                      \
        software-properties-common                                                                 \
        sudo                                                                                       \
        wget                                                                                       \
        zsh                                                                                        \
    && rm -rf /var/lib/apt/lists/*

# GCC 13 is installed from the Ubuntu toolchain PPA because Humble's base
# image is Ubuntu 22.04, whose default GCC is older than this template expects.
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y                                              \
    && apt-get update                                                                              \
    && apt-get install --no-install-recommends -y                                                  \
        gcc-${GCC_VERSION}                                                                         \
        g++-${GCC_VERSION}                                                                         \
    && update-alternatives                                                                         \
        --install /usr/bin/gcc gcc /usr/bin/gcc-${GCC_VERSION} ${GCC_VERSION}                      \
        --slave /usr/bin/g++ g++ /usr/bin/g++-${GCC_VERSION}                                       \
    && add-apt-repository --remove ppa:ubuntu-toolchain-r/test -y                                  \
    && rm -rf /var/lib/apt/lists/*

# LLVM tools are installed from apt.llvm.org so clangd, clang-format, and
# clang-tidy share one version and match the repository config files.
RUN install -d -m 0755 /etc/apt/keyrings                                                           \
    && wget -qO /etc/apt/keyrings/apt.llvm.org.asc https://apt.llvm.org/llvm-snapshot.gpg.key      \
    && echo "deb [signed-by=/etc/apt/keyrings/apt.llvm.org.asc] http://apt.llvm.org/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-${LLVM_VERSION} main" \
        > /etc/apt/sources.list.d/apt.llvm.org.list                                                \
    && apt-get update                                                                              \
    && apt-get install --no-install-recommends -y                                                  \
        clang-format-${LLVM_VERSION}                                                               \
        clang-tidy-${LLVM_VERSION}                                                                 \
        clangd-${LLVM_VERSION}                                                                     \
    && update-alternatives                                                                         \
        --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${LLVM_VERSION} 100     \
    && update-alternatives                                                                         \
        --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${LLVM_VERSION} 100           \
    && update-alternatives                                                                         \
        --install /usr/bin/clangd clangd /usr/bin/clangd-${LLVM_VERSION} 100                       \
    && rm -rf /var/lib/apt/lists/*

# Create the default non-root ROS user. The entrypoint can later remap this
# UID/GID to match the mounted workspace owner.
RUN groupadd --gid ${USER_GID} ${USERNAME}                                                         \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /usr/bin/zsh ${USERNAME}                  \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME}                     \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

# Source ROS2 automatically for interactive Bash and Zsh shells. This keeps
# manual attach sessions and docker compose exec sessions consistent.
RUN {                                                                                              \
      echo "if [ -n \"\${BASH_VERSION:-}\" ]; then";                                               \
      echo "  source /opt/ros/humble/setup.bash";                                                  \
      echo "  eval \"\$(register-python-argcomplete3 ros2)\"";                                     \
      echo "  eval \"\$(register-python-argcomplete3 colcon)\"";                                   \
      echo "  export RCUTILS_COLORIZED_OUTPUT=1";                                                  \
      echo "fi";                                                                                   \
    } > /etc/profile.d/ros2-workspace.sh                                                           \
    && {                                                                                           \
      echo "";                                                                                     \
      echo "# Source ROS 2 setup for interactive Bash shells.";                                    \
      echo "if [ -f /etc/profile.d/ros2-workspace.sh ]; then";                                     \
      echo "  source /etc/profile.d/ros2-workspace.sh";                                            \
      echo "fi";                                                                                   \
    } >> /etc/bash.bashrc                                                                          \
    && {                                                                                           \
      echo "source /opt/ros/humble/setup.zsh";                                                     \
      echo "eval \"\$(register-python-argcomplete3 ros2)\"";                                       \
      echo "eval \"\$(register-python-argcomplete3 colcon)\"";                                     \
      echo "export RCUTILS_COLORIZED_OUTPUT=1";                                                    \
    } > /etc/zsh/ros2-workspace.zsh                                                                \
    && {                                                                                           \
      echo "if [ -f /etc/zsh/ros2-workspace.zsh ]; then";                                          \
      echo "  source /etc/zsh/ros2-workspace.zsh";                                                 \
      echo "fi";                                                                                   \
    } > /etc/zsh/zprofile                                                                          \
    && {                                                                                           \
      echo "";                                                                                     \
      echo "# Source ROS 2 setup for interactive Zsh shells.";                                     \
      echo "if [ -f /etc/zsh/ros2-workspace.zsh ]; then";                                          \
      echo "  source /etc/zsh/ros2-workspace.zsh";                                                 \
      echo "fi";                                                                                   \
    } >> /etc/zsh/zshrc

# The ros user's default Zsh config delegates to the system ROS2 shell setup.
RUN {                                                                                              \
      echo "if [ -f /etc/zsh/ros2-workspace.zsh ]; then";                                          \
      echo "  source /etc/zsh/ros2-workspace.zsh";                                                 \
      echo "fi";                                                                                   \
    } > /home/${USERNAME}/.zshrc                                                                   \
    && chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.zshrc

# Local rosdep rule: ament_python is a package build type, not a system
# dependency. Mapping it to no Ubuntu packages keeps rosdep install quiet for
# this template workspace.
RUN install -d -m 0755 /etc/ros/rosdep /etc/ros/rosdep/sources.list.d                               \
    && {                                                                                            \
      echo "ament_python:";                                                                         \
      echo "  ubuntu: []";                                                                          \
    } > /etc/ros/rosdep/ros2-workspace-local.yaml                                                   \
    && echo "yaml file:///etc/ros/rosdep/ros2-workspace-local.yaml"                                 \
        > /etc/ros/rosdep/sources.list.d/00-ros2-workspace-local.list

# Prime rosdep metadata at image build time; users can still run rosdep update
# later to refresh the cache.
RUN rosdep update

# Stable VS Code and compose workspace path used throughout the repository.
RUN mkdir -p /workspaces/ros2-ws                                                                   \
    && chown -R ${USERNAME}:${USERNAME} /workspaces

# The entrypoint fixes workspace/home ownership after the project is bind
# mounted, then runs the requested shell or command as the ros user.
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 0755 /usr/local/bin/entrypoint.sh

USER ${USERNAME}
WORKDIR /workspaces/ros2-ws

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/zsh", "-l"]
