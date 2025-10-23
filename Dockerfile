FROM osrf/ros:humble-desktop-full

# Install dependencies
RUN apt-get update                \
  && apt-get install -y           \
  sudo                            \
  wget                            \
  ninja-build                     \
  rsync                           \
  gdb                             \
  gdbserver                       \
  && apt-get autoremove -y        \
  && apt-get clean -y             \
  && rm -rf /var/lib/apt/lists/*

# Install gcc 13
RUN apt update                                                                                     \
  && apt install software-properties-common -y                                                     \
  && add-apt-repository ppa:ubuntu-toolchain-r/test -y                                             \
  && apt update                                                                                    \
  && apt install gcc-13 g++-13 -y                                                                  \
  && update-alternatives                                                                           \
  --install /usr/bin/gcc gcc /usr/bin/gcc-13 13                                                    \
  --slave   /usr/bin/g++ g++ /usr/bin/g++-13                                                       \
  && gcc --version # check version                                                                 \
  && g++ --version # check version                                                                 \
  && add-apt-repository --remove ppa:ubuntu-toolchain-r/test -y                                    \
  && apt update                                                                                    \
  && apt autoremove -y                                                                             \
  && apt clean -y                                                                                  \
  && rm -rf /var/lib/apt/lists/*

# Install clang 22
RUN  apt install -y wget                                                                           \
  && wget -qO /etc/apt/trusted.gpg.d/apt.llvm.org.asc https://apt.llvm.org/llvm-snapshot.gpg.key   \
  && echo "deb http://apt.llvm.org/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc) main" | tee /etc/apt/sources.list.d/apt.llvm.org.list \
  && apt update                                                                                    \
  && apt-get install clangd-22 clang-format-22 clang-tidy-22 -y                                    \
  && update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-22 100 \
  && update-alternatives --install /usr/bin/clangd       clangd       /usr/bin/clangd-22       100 \
  && update-alternatives --install /usr/bin/clang-tidy   clang-tidy   /usr/bin/clang-tidy-22   100 \
  && clang-format --version # check version                                                        \
  && clangd       --version # check version                                                        \
  && clang-tidy   --version # check version                                                        \
  && apt autoremove -y                                                                             \
  && apt clean -y                                                                                  \
  && rm -rf /var/lib/apt/lists/*

# Install Zsh and Oh My Zsh.
RUN apt-get install -y wget                                                                        \
  && sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.1/zsh-in-docker.sh)" -- \
  -t gnzh                                                                                          \
  -p git                                                                                           \
  -p https://github.com/zsh-users/zsh-autosuggestions                                              \
  -p https://github.com/zsh-users/zsh-completions                                                  \
  -p https://github.com/zsh-users/zsh-syntax-highlighting                                          \
  && chsh -s $(which zsh) $USERNAME                                                                \
  && zsh --version # check version                                                                 \
  && apt-get autoremove -y                                                                         \
  && apt-get clean -y                                                                              \
  && rm -rf /var/lib/apt/lists/*

# Add ROS underlay packages and auto-completion.
RUN echo "\n# ROS"                                        >> $HOME/.bashrc                         \
  && echo "source /opt/ros/humble/setup.bash"             >> $HOME/.bashrc                         \
  && echo 'eval "$(register-python-argcomplete3 ros2)"'   >> $HOME/.bashrc                         \
  && echo 'eval "$(register-python-argcomplete3 colcon)"' >> $HOME/.bashrc                         \
  && echo "export RCUTILS_COLORIZED_OUTPUT=1"             >> $HOME/.bashrc                         \
  && echo "\n# ROS"                                       >> $HOME/.zshrc                          \
  && echo "source /opt/ros/humble/setup.zsh"              >> $HOME/.zshrc                          \
  && echo 'eval "$(register-python-argcomplete3 ros2)"'   >> $HOME/.zshrc                          \
  && echo 'eval "$(register-python-argcomplete3 colcon)"' >> $HOME/.zshrc                          \
  && echo "export RCUTILS_COLORIZED_OUTPUT=1"             >> $HOME/.zshrc                          \
  && rosdep update

RUN     mkdir /workspaces
VOLUME  /workspaces
WORKDIR /workspaces

# Start zsh shell when the container starts
ENTRYPOINT [ "zsh" ]
CMD ["-l"]
