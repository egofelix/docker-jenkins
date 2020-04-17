FROM jenkins/jenkins:lts

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Basic Install
RUN apt-get update && apt-get install -y --no-install-recommends curl wget apt-transport-https && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y --no-install-recommends dpkg-dev dos2unix apt-utils zip docker-ce supervisor && \
    mkdir -p /etc/docker/ && \
    echo '{ "experimental": true }' > /etc/docker/daemon.json

# Net Core
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list && chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-2.1 && \
    rm -rf /usr/share/dotnet/sdk/NuGetFallbackFolder

# MegaFuse
# ARMHF
RUN apt-get install -y crossbuild-essential-armhf g++-arm-linux-gnueabihf
RUN apt-get install -y -o Dpkg::Options::="--force-overwrite" libcrypto++-dev:armhf libcurl4-openssl-dev:armhf libdb5.3++-dev:armhf libfreeimage-dev:armhf libreadline-dev:armhf libfuse-dev:armhf libcurl4-openssl-dev:armhf
# AMD64
RUN apt-get install -y -o Dpkg::Options::="--force-overwrite" libcrypto++-dev libcurl4-openssl-dev libdb5.3++-dev libfreeimage-dev libreadline-dev libfuse-dev libcurl4-openssl-dev

# Cleanup
RUN rm -rf /var/lib/apt/lists/*
  
COPY etc/ /etc/

ENTRYPOINT /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf --pidfile /run/supervisord.pid
