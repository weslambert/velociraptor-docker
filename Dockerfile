FROM ubuntu:18.04
LABEL version="Velociraptor v0.4.6"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="Wes Lambert, @therealwlambert"
ENV VERSION="0.4.6"
COPY ./entrypoint .
RUN chmod +x entrypoint && \
    apt-get update && \
    apt-get install -y wget && \
    # Create dirs for Velox binaries
    mkdir -p /opt/velociraptor && \
    for i in linux mac windows; do mkdir -p /opt/velociraptor/$i; done && \
    # Get Velox binaries
    wget -O /opt/velociraptor/linux/velociraptor https://github.com/Velocidex/velociraptor/releases/download/v$VERSION/velociraptor-v$VERSION-linux-amd64 && \
    wget -O /opt/velociraptor/mac/velociraptor_client https://github.com/Velocidex/velociraptor/releases/download/v$VERSION/velociraptor-v$VERSION-darwin-amd64 && \
    wget -O /opt/velociraptor/windows/velociraptor_client.exe https://github.com/Velocidex/velociraptor/releases/download/v$VERSION/velociraptor-v$VERSION-windows-amd64.exe && \
    # Clean up 
    apt-get remove -y --purge wget && \
    apt-get clean
WORKDIR /velociraptor 
CMD ["/entrypoint"]

