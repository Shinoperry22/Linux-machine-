# Use the official Kali rolling image
FROM kalilinux/kali-rolling

# Avoid interactive prompts during apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install basic dev tools + Docker CLI + Docker engine (for DinD)
RUN apt-get update && apt-get install -y \
    sudo \
    git \
    curl \
    wget \
    vim \
    ca-certificates \
    lsb-release \
    gnupg \
    iptables \
    docker.io \
    docker-compose-plugin \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a non-root user with passwordless sudo (better for dev containers)
ARG USERNAME=devuser
RUN useradd -ms /bin/bash $USERNAME \
    && echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Add the user to the docker group so it can run docker commands without sudo
RUN groupadd -f docker && usermod -aG docker $USERNAME

# Switch to the non-root user
USER $USERNAME

# Set a sensible workdir
WORKDIR /workspaces

# Start Docker daemon automatically when container starts
# (This is the key for Docker-in-Docker in devcontainers)
CMD ["sh", "-c", "sudo dockerd & sleep 3 && bash"]