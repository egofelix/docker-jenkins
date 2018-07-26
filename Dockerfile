FROM jenkins/jenkins:lts

USER root

RUN apt-get update && apt-get install -y wget
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN chown root:root /etc/apt/trusted.gpg.d/microsoft.asc.gpg
RUN wget -qO- https://packages.microsoft.com/config/debian/9/prod.list > /etc/apt/sources.list.d/microsoft-prod.list
RUN chown root:root /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-get update && apt-get install -y dotnet-hosting-2.0.8

USER jenkins
