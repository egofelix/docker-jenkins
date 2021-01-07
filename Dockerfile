FROM alpine

MAINTAINER EgoFelix <docker@egofelix.de>

RUN apk --no-cache add \
      jenkins \
      npm \
      wget \
      curl \
      git \
      unzip \
      dpkg \
      dpkg-dev \
      xz \
      gnupg \
      dos2unix \
      supervisor \
      openssh && \
    rm -rf /usr/share/webapps/jenkins/jenkins.war && \
    curl -L --output /root/dotnetsdk.tar.gz \
      https://download.visualstudio.microsoft.com/download/pr/a84c2dee-3074-4c27-9b31-af0bc9a9ebcf/a8eb9a11b81c5b7119cf1578632ed186/dotnet-sdk-5.0.101-linux-musl-x64.tar.gz && \
    mkdir -p /root/dotnet && \
    tar vzxf /root/dotnetsdk.tar.gz -C /root/dotnet && \
    rm /root/dotnetsdk.tar.gz && \
    mkdir -p /tools && \
    curl -L --output /tools/ReportGenerator.nupkg \
      https://www.nuget.org/api/v2/package/ReportGenerator/4.8.3 && \
    unzip -o /tools/ReportGenerator.nupkg -d /tools/ReportGenerator && \
    rm /tools/ReportGenerator.nupkg

ENV JENKINS_HOME=/jenkins
ENV DOTNET_ROOT=/root/dotnet
ENV PATH=$PATH:/root/dotnet
ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

COPY jenkins.ini /etc/supervisor.d/

CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisord.conf
