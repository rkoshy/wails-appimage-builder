FROM debian:bookworm

# Install system dependencies for Wails builds and AppImage packaging
RUN apt-get update && \
    apt-get install -y \
        wget \
        ca-certificates \
        nodejs \
        npm \
        libgtk-3-dev \
        libwebkit2gtk-4.0-dev \
        mingw-w64 \
        nsis \
        git \
        fuse \
        file \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go 1.22.10
RUN wget -q https://go.dev/dl/go1.22.10.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.22.10.linux-amd64.tar.gz && \
    rm go1.22.10.linux-amd64.tar.gz

# Set Go path
ENV PATH="/usr/local/go/bin:/root/go/bin:${PATH}"
ENV GOPATH="/root/go"

# Install Wails CLI
RUN go install github.com/wailsapp/wails/v2/cmd/wails@latest

# Install linuxdeploy for AppImage packaging
RUN wget -q https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
    -O /usr/local/bin/linuxdeploy && \
    chmod +x /usr/local/bin/linuxdeploy

# Verify installations (skip linuxdeploy --version as it needs FUSE which isn't available during build)
RUN go version && \
    node --version && \
    npm --version && \
    wails version && \
    echo "linuxdeploy installed at /usr/local/bin/linuxdeploy"

WORKDIR /workspace
