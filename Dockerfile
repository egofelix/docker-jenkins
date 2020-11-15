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
    echo '{ "experimental": true }' > /etc/docker/daemon.json

# Net Core & Powershell
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list && chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-5.0 powershell && \
    rm -rf /usr/share/dotnet/sdk/NuGetFallbackFolder

# CodeCoverage for Net Core
RUN mkdir /tools && \
    wget https://www.nuget.org/api/v2/package/ReportGenerator/4.6.0 -qO /tools/ReportGenerator.nupkg
#    wget https://www.nuget.org/api/v2/package/Microsoft.CodeCoverage/16.6.1 -qO /tools/Microsoft.CodeCoverage.nupkg

RUN apt-get install -y --no-install-recommends zip
RUN mkdir /tools/ReportGenerator
RUN unzip -o /tools/ReportGenerator.nupkg -d /tools/ReportGenerator
#RUN unzip -o /tools/Microsoft.CodeCoverage.nupkg

# Dotnet retire
RUN dotnet tool install -g dotnet-retire

# Fix Nuget
RUN mkdir -p /tmp/NuGetScratch
RUN chown -R jenkins:jenkins /tmp/NuGetScratch

# Allow Jenkins to call docker
RUN apt-get install -y --no-install-recommends qemu-user
RUN usermod -aG docker jenkins

# MegaFuse
# ARMHF
#RUN dpkg --add-architecture armhf && apt-get update
#RUN apt-get install -y crossbuild-essential-armhf g++-arm-linux-gnueabihf
#RUN apt-get install -y -o Dpkg::Options::="--force-overwrite" libcrypto++-dev:armhf libcurl4-openssl-dev:armhf libdb5.3++-dev:armhf libfreeimage-dev:armhf libreadline-dev:armhf libfuse-dev:armhf libcurl4-openssl-dev:armhf
# AMD64
#RUN apt-get install -y -o Dpkg::Options::="--force-overwrite" libcrypto++-dev libcurl4-openssl-dev libdb5.3++-dev libfreeimage-dev libreadline-dev libfuse-dev libcurl4-openssl-dev

# Cleanup
RUN rm -rf /var/lib/apt/lists/*
  
COPY etc/ /etc/
COPY buildbot.sh /opt/buildbot
COPY testbot.ps1 /opt/testbot

RUN chmod +x /opt/buildbot
RUN chmod +x /opt/testbot

ENTRYPOINT /usr/bin/supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf --pidfile /run/supervisord.pid
