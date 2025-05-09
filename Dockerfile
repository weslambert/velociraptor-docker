FROM ubuntu:22.04
LABEL version="Velociraptor v0.74.2"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="Wes Lambert, @therealwlambert"
COPY ./entrypoint .
RUN chmod +x entrypoint && \
    apt-get update && \
    apt-get install -y curl wget jq rsync && \
    # Create dirs for Velo binaries
    mkdir -p /opt/velociraptor && \
    for i in linux mac windows; do mkdir -p /opt/velociraptor/$i; done && \
    # Set Velociraptor version and base URL
    VELO_VERSION="v0.74.2" && \
    VELO_BASE_URL="v0.74" && \
    # Get Velociraptor binaries for specific version
    WINDOWS_EXE="https://github.com/Velocidex/velociraptor/releases/download/${VELO_BASE_URL}/velociraptor-${VELO_VERSION}-windows-amd64.exe" && \
    WINDOWS_MSI="https://github.com/Velocidex/velociraptor/releases/download/${VELO_BASE_URL}/velociraptor-${VELO_VERSION}-windows-amd64.msi" && \
    LINUX_BIN="https://github.com/Velocidex/velociraptor/releases/download/${VELO_BASE_URL}/velociraptor-${VELO_VERSION}-linux-amd64-musl" && \
    MAC_BIN="https://github.com/Velocidex/velociraptor/releases/download/${VELO_BASE_URL}/velociraptor-${VELO_VERSION}-darwin-amd64" && \
    wget -O /opt/velociraptor/linux/velociraptor "$LINUX_BIN" && \
    wget -O /opt/velociraptor/mac/velociraptor_client "$MAC_BIN" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.exe "$WINDOWS_EXE" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.msi "$WINDOWS_MSI" && \
    # Clean up
    apt-get remove -y --purge wget && \
    apt-get clean
WORKDIR /velociraptor
CMD ["/entrypoint"]
