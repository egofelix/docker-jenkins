FROM jenkins/jenkins:lts

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget apt-transport-https && \
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg && chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg && \
    wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list && chown root:root /etc/apt/sources.list.d/microsoft-prod.list && \
    apt-get install -y --no-install-recommends dotnet-sdk-2.1 dpkg-dev dos2unix apt-utils zip && \
    rm -rf /var/lib/apt/lists/*

USER jenkins
