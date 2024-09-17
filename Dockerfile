FROM debian:latest 

WORKDIR /build

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
    && rm -rf /var/lib/apt/lists/* 

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs 

RUN apt-get update && apt-get install -y docker.io && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    mkdir -p /root/.cargo/bin && \
    . $HOME/.cargo/env && \
    rustup target add wasm32-unknown-unknown

RUN git clone --recursive https://github.com/MercuryWorkshop/anuraOS .

ENV PATH="/root/.cargo/bin:${PATH}"

RUN make all -B

EXPOSE 8000

USER root

CMD ["make", "server"]
