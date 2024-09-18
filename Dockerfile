FROM debian:latest 

# Set the working directory
WORKDIR /app

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    make \
    clang \
    gcc \
    inotify-tools \
    openjdk-17-jdk \
    gnupg2 \
    uuid-runtime \
    jq \
    lsb-release \
    sudo \
    && rm -rf /var/lib/apt/lists/* 

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs 

# Install Docker
RUN apt-get update && apt-get install -y docker.io && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    mkdir -p /root/.cargo/bin && \
    . $HOME/.cargo/env && \
    rustup target add wasm32-unknown-unknown

# Clone the repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS /app

# Set the path for cargo binaries
ENV PATH="/root/.cargo/bin:${PATH}"

# Build the project
RUN newgrp docker && yes "3" | make rootfs && make all

# Expose the application port
EXPOSE 8000

# Create a new user
RUN useradd -m USER && echo "USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Change ownership of the /app directory to the new user
RUN chown -R USER:USER /app

# Switch to the new user
USER USER

# Default command to run the application
CMD ["make", "server"]
