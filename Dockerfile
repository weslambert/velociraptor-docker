FROM ubuntu:22.04
ARG VELOX_VERSION
LABEL version="Velociraptor $VELOX_VERSION"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="Wes Lambert, @therealwlambert"
COPY ./entrypoint .
RUN chmod +x entrypoint && \
    apt-get update && \
    apt-get install -y curl jq rsync && \
    # Create dirs for Velo binaries
    mkdir -p /opt/velociraptor && \
    for i in linux mac windows; do mkdir -p /opt/velociraptor/$i; done && \
    # Get Velox binaries
    VELOX_RELEASE="${VELOX_VERSION%.*}"; \
    WINDOWS_EXE="https://github.com/Velocidex/velociraptor/releases/download/${VELOX_RELEASE}/velociraptor-${VELOX_VERSION}-windows-amd64.exe" && \
    WINDOWS_MSI="https://github.com/Velocidex/velociraptor/releases/download/${VELOX_RELEASE}/velociraptor-${VELOX_VERSION}-windows-amd64.msi" && \
    LINUX_BIN="https://github.com/Velocidex/velociraptor/releases/download/${VELOX_RELEASE}/velociraptor-${VELOX_VERSION}-linux-amd64" && \
    MAC_BIN="https://github.com/Velocidex/velociraptor/releases/download/${VELOX_RELEASE}/velociraptor-${VELOX_VERSION}-darwin-amd64" && \
    curl -fL "$WINDOWS_EXE" -o /opt/velociraptor/windows/velociraptor_client.exe || echo "velociraptor-${VELOX_VERSION}-windows-amd64.exe not available" && \
    curl -fL "$WINDOWS_MSI" -o /opt/velociraptor/windows/velociraptor_client.msi || echo "velociraptor-${VELOX_VERSION}-windows-amd64.msi not available" && \
    curl -fL "$LINUX_BIN" -o /opt/velociraptor/linux/velociraptor || echo "velociraptor-${VELOX_VERSION}-linux-amd64 not available" && \
    curl -fL "$MAC_BIN" -o /opt/velociraptor/mac/velociraptor_client || echo "velociraptor-${VELOX_VERSION}-darwin-amd64 not available" && \
    # Clean up
    apt-get remove -y --purge wget && \
    apt-get clean
WORKDIR /velociraptor
CMD ["/entrypoint"]
