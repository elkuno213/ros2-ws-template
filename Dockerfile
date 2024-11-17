FROM osrf/ros:humble-desktop-full

# Install dependencies
RUN apt-get update                  \
    && apt-get install -y           \
      sudo                          \
      ninja-build                   \
      rsync                         \
      gdb                           \
      gdbserver                     \
    && apt-get autoremove -y        \
    && apt-get clean -y             \
    && rm -rf /var/lib/apt/lists/*

# Install llvm 16
RUN git clone https://gist.github.com/96573409aee8d12951337621ef07b027.git /tmp/install-llvm \
    && chmod +x /tmp/install-llvm/install.sh                                                 \
    && /tmp/install-llvm/install.sh 16                                                       \
    && rm -rf /tmp/install-llvm

# Arguments.
ARG USERNAME=nonroot
ARG UID=1000
ARG GID=1000

# Environment variables.
ENV USERNAME=$USERNAME
ENV UID=$UID
ENV GID=$GID

# Create the user.
RUN groupadd --gid $GID $USERNAME \
    && adduser                    \
      --disabled-password         \
      --disabled-login            \
      --gecos ""                  \
      --uid $UID                  \
      --gid $GID                  \
      $USERNAME                   \
    && usermod -aG sudo $USERNAME \
    && groups $USERNAME           \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" | tee -a /etc/sudoers.d/$USERNAME

# Create /workspaces folder owned by nonroot.
RUN mkdir /workspaces && chown $USERNAME:$USERNAME /workspaces
VOLUME /workspaces
WORKDIR /workspaces

# Set the default user.
USER $USERNAME

# Install Zsh and Oh My Zsh.
RUN git clone https://gist.github.com/fe0d401310134bb6012beb3627c367ee.git /tmp/install-zsh \
    && sudo chmod +x /tmp/install-zsh/install.sh                                            \
    && /tmp/install-zsh/install.sh                                                          \
    && sudo rm -rf /tmp/install-zsh

# Add ROS underlay packages and auto-completion.
RUN echo "\n# ROS" >> $HOME/.bashrc                                                                \
    && echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc                                   \
    && echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash\n" >> $HOME/.bashrc \
    && echo "\n# ROS" >> $HOME/.zshrc                                                              \
    && echo "source /opt/ros/humble/setup.zsh" >> $HOME/.zshrc                                     \
    && echo 'eval "$(register-python-argcomplete3 ros2)"' >> $HOME/.zshrc                          \
    && echo 'eval "$(register-python-argcomplete3 colcon)"' >> $HOME/.zshrc                        \
    && rosdep update

# Start zsh shell when the container starts
ENTRYPOINT [ "zsh" ]
CMD ["-l"]
