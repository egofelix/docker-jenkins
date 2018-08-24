FROM jenkins/jenkins:lts

MAINTAINER EgoFelix <docker@egofelix.de>

USER root

RUN apt-get update && apt-get install -y wget apt-transport-https
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
RUN echo 'deb https://apt.dockerproject.org/repo debian-stretch main' > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y dotnet-sdk-2.1 dpkg-dev dos2unix apt-utils zip docker-engine
RUN usermod -a -G docker jenkins

USER jenkins
