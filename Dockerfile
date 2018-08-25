FROM jenkins/jenkins:lts-slim

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

RUN apt-get update && apt-get install -y --no-install-recommends wget apt-transport-https && \
    apt-key adv --recv-keys 58118E89F3A912897C070ADBF76221572C52609D && \
    echo 'deb https://apt.dockerproject.org/repo debian-stretch main' > /etc/apt/sources.list.d/docker.list && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list && chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-2.1 dpkg-dev dos2unix apt-utils zip docker-engine supervisor && \
    rm -rf /usr/share/dotnet/sdk/NuGetFallbackFolder && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/docker/ && \
    echo '{ "experimental": true }' > /etc/docker/daemon.json

COPY etc/ /etc/

ENTRYPOINT /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf --pidfile /run/supervisord.pid
