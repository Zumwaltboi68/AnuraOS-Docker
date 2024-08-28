# Use an official Ubuntu as the base image
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

# Install required packages and clean up to reduce image size
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    build-essential \
    clang \
    gcc \
    make \
    openjdk-17-jdk \
    inotify-tools \
    python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm@latest && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install rustup (Rust installer and version management tool)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Set up Rust (ensure environment variables are correctly loaded)
RUN source /usr/local/cargo/env && \
    rustup update && \
    rustup default stable

# Clone the Anura OS repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS.git /anuraOS

# Set working directory
WORKDIR /anuraOS

# Build the project
RUN make all

# Expose the port (assuming the server runs on port 8080)
EXPOSE 8080

# Command to run the server
CMD ["make", "server"]
