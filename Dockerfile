# Build stage
FROM debian:bullseye-slim AS builder
# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev \
    unzip git python3 python3-zmq zlib1g-dev wget bsdmainutils automake libssl-dev \
    libcurl4-openssl-dev libprotobuf-dev protobuf-compiler libgtest-dev \
    curl ca-certificates
# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"
WORKDIR /build
# We are currently IN the repo, so we copy files instead of cloning again
COPY . .
# Build
RUN ./zcutil/build.sh -j$(nproc)
# Final stage
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y \
    libgomp1 libcurl4 curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /root/.junocash
# Copy binaries
COPY --from=builder /build/src/junocashd /usr/local/bin/
COPY --from=builder /build/src/junocash-cli /usr/local/bin/

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose ports (P2P and RPC)
EXPOSE 8232 8233
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["junocashd", "-printtoconsole"]
