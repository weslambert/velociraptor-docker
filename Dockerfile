FROM ubuntu:22.04
LABEL version="Velociraptor v0.73.4"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="Wes Lambert, @therealwlambert"
COPY ./entrypoint .
RUN chmod +x entrypoint && \
    apt-get update && \
    apt-get install -y curl wget jq rsync && \
    # Create dirs for Velo binaries
    mkdir -p /opt/velociraptor && \
    for i in linux mac windows; do mkdir -p /opt/velociraptor/$i; done && \
    # Get Velox binaries
    WINDOWS_EXE=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("windows-amd64.exe$"))][0]') && \
    WINDOWS_MSI=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("windows-amd64.msi$"))][0]') && \
    WINDOWS_LEGACY=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("amd64-legacy.exe$"))][0]') && \
    WINDOWS_LEGACY_386=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("windows-386-legacy.exe$"))][0]') && \
    LINUX_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("linux-amd64$"))][0]') && \
    LINUX_MUSL_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("linux-amd64-musl$"))][0]') && \
    LINUX_ARM_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("linux-arm64$"))][0]') && \
    FREEBSD_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("freebsd-amd64$"))][0]') && \
    MAC_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("darwin-amd64$"))][0]') && \
    MAC_ARM_BIN=$(curl -s https://api.github.com/repos/velocidex/velociraptor/releases/latest | jq -r '[.assets | sort_by(.created_at) | reverse | .[] | .browser_download_url | select(test("darwin-arm64$"))][0]') && \
    #copy clients
    wget -O /opt/velociraptor/linux/velociraptor_client "$LINUX_BIN" && \
    wget -O /opt/velociraptor/linux/velociraptor_client_musl "$LINUX_MUSL_BIN" && \
    wget -O /opt/velociraptor/linux/velociraptor_client_arm "$LINUX_ARM_BIN" && \
    wget -O /opt/velociraptor/linux/velociraptor_client_freebsd "$FREEBSD_BIN" && \
    wget -O /opt/velociraptor/mac/velociraptor_client "$MAC_BIN" && \
    wget -O /opt/velociraptor/mac/velociraptor_client_arm "$MAC_ARM_BIN" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.exe "$WINDOWS_EXE" && \
    wget -O /opt/velociraptor/windows/velociraptor_client.msi "$WINDOWS_MSI" && \
    wget -O /opt/velociraptor/windows/velociraptor_client_legacy64.exe "$WINDOWS_LEGACY" && \
    wget -O /opt/velociraptor/windows/velociraptor_client_legacy32.exe "$WINDOWS_LEGACY_386" && \
    # Clean up
    apt-get remove -y --purge wget && \
    apt-get clean
WORKDIR /velociraptor
CMD ["/entrypoint"]
