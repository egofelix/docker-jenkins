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
    mkdir /tools && \
    curl -L --output /tools/dotnetsdk.tar.gz \
      https://download.visualstudio.microsoft.com/download/pr/bf715f3d-ab8a-42a1-83ce-f6e1524a9f58/8d970618369fe8e6917a49c05aac58db/dotnet-sdk-5.0.102-linux-musl-x64.tar.gz && \
    mkdir -p /tools/dotnet && \
    tar vzxf /tools/dotnetsdk.tar.gz -C /tools/dotnet && \
    rm /tools/dotnetsdk.tar.gz && \
    curl -L --output /tools/ReportGenerator.nupkg \
      https://www.nuget.org/api/v2/package/ReportGenerator/4.8.3 && \
    unzip -o /tools/ReportGenerator.nupkg -d /tools/ReportGenerator && \
    rm /tools/ReportGenerator.nupkg

ENV JENKINS_HOME=/jenkins
ENV DOTNET_ROOT=/tools/dotnet
ENV PATH=$PATH:/tools/dotnet
ENV NUGET_XMLDOC_MODE=skip
ENV DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
ENV DOTNET_CLI_HOME=/tmp/dotnet

COPY permissions.ini jenkins.ini /etc/supervisor.d/
COPY permissions.sh /permissions.sh


CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisord.conf
