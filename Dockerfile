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
    docker.io \
    expect \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    . $HOME/.cargo/env && \
    rustup target add wasm32-unknown-unknown

# Clone the repository
RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS /app

# Set the path for cargo binaries
ENV PATH="/root/.cargo/bin:${PATH}"

# Add the new user and make sure they have sudo access
RUN useradd -m USER && echo "USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add USER to the Docker group
RUN usermod -aG docker USER

# Change ownership of the /app directory to the new user
RUN chown -R USER:USER /app

# Copy the entrypoint script to start Docker daemon
COPY dockerd-entrypoint.sh /usr/bin/dockerd-entrypoint.sh
RUN chmod +x /usr/bin/dockerd-entrypoint.sh

# Automate the "make rootfs" process by providing input "2"
RUN echo '#!/usr/bin/expect\n\
spawn make rootfs\n\
expect "Choose an option"\n\
send "2\r"\n\
expect eof' > /app/automate_make_rootfs.exp && chmod +x /app/automate_make_rootfs.exp

# Switch to the new user
USER USER

# Start the Docker daemon and run the automated make rootfs
ENTRYPOINT ["/usr/bin/dockerd-entrypoint.sh"]

# Automatically run the make rootfs with "2" as input and then continue with the build
CMD ["/app/automate_make_rootfs.exp", "&&", "make", "all", "&&", "make", "server"]

# Expose the application port
EXPOSE 8000
