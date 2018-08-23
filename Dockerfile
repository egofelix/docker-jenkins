FROM jenkins/jenkins:lts

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

RUN apt-get update && apt-get install -y wget apt-transport-https
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN echo 'deb https://apt.dockerproject.org/repo debian-stretch main' > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y dotnet-sdk-2.1 dpkg-dev dos2unix apt-utils zip docker-engine

USER jenkins
