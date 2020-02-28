FROM ubuntu:18.04
LABEL version="Velociraptor v0.3.9"
LABEL description="Velociraptor server in a Docker container"
LABEL maintainer="Wes Lambert, @therealwlambert"
ENV VERSION="0.3.9"

COPY ./entrypoint .
RUN chmod +x entrypoint && \
    apt-get update && \
    apt-get install -y wget && \
    mkdir -p /velociraptor && \    
    mkdir -p /velociraptor/clients/linux && \
    mkdir -p /velociraptor/clients/mac && \
    mkdir -p /velociraptor/clients/windows && \
    wget -O /velociraptor/velociraptor https://github.com/Velocidex/velociraptor/releases/download/v$VERSION/velociraptor-v$VERSION-linux-amd64 && \
    chmod +x /velociraptor/velociraptor && \
    cp /velociraptor/velociraptor /velociraptor/clients/linux/velociraptor_client && \
    wget -O /velociraptor/clients/mac/velociraptor_client https://github.com/Velocidex/velociraptor/releases/download/v$VERSION/velociraptor-v$VERSION-darwin-amd64 && \
    wget -O /velociraptor/clients/windows/velociraptor_client.exe https://github.com/Velocidex/velociraptor/releases/download/v$VERSION/velociraptor-v$VERSION-windows-amd64.exe && \
    chmod -R +x /velociraptor/clients && \
    apt-get clean
WORKDIR /velociraptor 
CMD ["/entrypoint"]

