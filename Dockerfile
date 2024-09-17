# Use the bookworm:slim base image
FROM debian:latest

# Set the working directory
WORKDIR /build

# Install required packages
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
    lsb-release \
    && rm -rf /var/lib/apt/lists/* 

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs 

# Install Docker (if needed for your application, typically, it's not done within Render)
RUN apt-get update && apt-get install -y docker.io && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    mkdir -p /root/.cargo/bin && \
    . $HOME/.cargo/env && \
    rustup target add wasm32-unknown-unknown

# Clone the AnuraOS repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS .

# Set environment variables for Rust
ENV PATH="/root/.cargo/bin:${PATH}"

# Build using make, and automatically provide '2' as input to the rootfs command
RUN make all && make rootfs && (echo 2 | make rootfs)

# Set the port that the app will run on
EXPOSE 8080

# Set the user to root for permission considerations
USER root

# Specify the command to run your app (make sure the target exists)
CMD ["make", "server"]
