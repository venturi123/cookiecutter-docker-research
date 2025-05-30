# Base image from NVIDIA with PyTorch
FROM nvcr.io/nvidia/pytorch:{{ cookiecutter.nvidia_docker_tag }}

# Use bash for the shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables using build arguments
ARG USER_UID
ARG USER_GID
ARG USERNAME=docker

# Switch to the root user to perform apt-get update and install sudo
USER root

# Output the provided USER_UID and USER_GID
RUN echo "Building with USER_UID=${USER_UID} and USER_GID=${USER_GID}"

# Set non-interactive frontend for APT
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages and clean up APT lists to reduce image size
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo tmux htop bash-completion curl && \
    rm -rf /var/lib/apt/lists/*

# Check if the user already exists; if so, modify UID and GID. Otherwise, create a new user and set up the home directory
RUN if id -u $USERNAME >/dev/null 2>&1; then \
        echo "User $USERNAME exists. Modifying UID and GID..."; \
        groupmod -g $USER_GID $USERNAME; \
        usermod -u $USER_UID -g $USER_GID $USERNAME; \
        chown -R $USER_UID:$USER_GID /home/$USERNAME; \
    else \
        echo "User $USERNAME does not exist. Creating user and home directory..."; \
        groupadd --gid $USER_GID $USERNAME; \
        useradd --uid $USER_UID --gid $USER_GID -m -d /home/$USERNAME $USERNAME; \
        chown -R $USER_UID:$USER_GID /home/$USERNAME; \
    fi \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to non-root user
USER $USERNAME

# Set environment variables
ENV PATH=/home/docker/.local/bin:$PATH
ENV PYTHONPATH=/home/docker/{{ cookiecutter.project_slug }}

# Copy configuration files with the correct ownership FIRST
COPY --chown=docker:docker docker/.bash_aliases docker/.tmux.conf docker/.bashrc /home/docker/
COPY --chown=docker:docker docker/htoprc /home/docker/.config/htop/htoprc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash
RUN export NVM_DIR="$HOME/.nvm" \
    && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
    && nvm install node

# Copy requirements and install dependencies
COPY --chown=docker:docker docker/requirements.txt /home/docker/requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /home/docker/requirements.txt

# Set the working directory
WORKDIR /home/docker/{{ cookiecutter.project_slug }}
