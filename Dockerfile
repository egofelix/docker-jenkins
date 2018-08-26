FROM jenkins/jenkins:lts

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN apt-get update && apt-get install -y --no-install-recommends curl wget apt-transport-https && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list && chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-2.1 dpkg-dev dos2unix apt-utils zip docker-ce supervisor && \
    rm -rf /usr/share/dotnet/sdk/NuGetFallbackFolder && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/docker/ && \
    echo '{ "experimental": true }' > /etc/docker/daemon.json

COPY etc/ /etc/

ENTRYPOINT /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf --pidfile /run/supervisord.pid
