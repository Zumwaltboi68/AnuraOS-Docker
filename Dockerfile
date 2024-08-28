# Use an official Ubuntu as the base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
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
    rustup

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Install the latest version of npm
RUN npm install -g npm@latest

# Set up rustup (Rust's installer and version management tool)
RUN rustup-init -y && \
    source $HOME/.cargo/env && \
    rustup update

# Clone the Anura OS repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS.git /anuraos

# Set working directory
WORKDIR /anuraOS

# Build the project
RUN make all

# Expose the necessary port (assuming the server runs on port 8080)
EXPOSE 8080

# Command to run the server
CMD ["make", "server"]
