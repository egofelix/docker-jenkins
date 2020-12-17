FROM jenkins/jenkins:lts

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1

# Basic Install
RUN apt-get update && apt-get install -y --no-install-recommends curl wget apt-transport-https gnupg && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y --no-install-recommends dpkg-dev dos2unix apt-utils zip docker-ce supervisor && \
    mkdir -p /etc/docker/ && \
    echo '{ "experimental": true }' > /etc/docker/daemon.json && \
# Net Core & Powershell
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list && chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-3.1 dotnet-sdk-5.0 powershell && \
    rm -rf /usr/share/dotnet/sdk/NuGetFallbackFolder && \
# CodeCoverage for Net Core
    mkdir /tools && \
    wget https://www.nuget.org/api/v2/package/ReportGenerator/4.6.0 -qO /tools/ReportGenerator.nupkg && \
# ReportGenerator
    apt-get install -y --no-install-recommends zip && \
    mkdir /tools/ReportGenerator && \
    unzip -o /tools/ReportGenerator.nupkg -d /tools/ReportGenerator && \
# Dotnet retire
    dotnet tool install -g dotnet-retire && \
# Fix Nuget
    mkdir -p /tmp/NuGetScratch && \
    chown -R jenkins:jenkins /tmp/NuGetScratch && \
# Allow Jenkins to call docker
    apt-get install -y --no-install-recommends qemu-user && \
    usermod -aG docker jenkins && \
# Cleanup
    rm -rf /var/lib/apt/lists/*
  
COPY etc/ /etc/
COPY buildbot.sh /opt/buildbot
COPY testbot.ps1 /opt/testbot

RUN chmod +x /opt/buildbot
RUN chmod +x /opt/testbot

ENTRYPOINT /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf --pidfile /run/supervisord.pid
