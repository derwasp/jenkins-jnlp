FROM jenkinsci/jnlp-slave

# Metadata
LABEL org.label-schema.vcs-url="https://github.com/derwasp/jenkins-jnlp" \
      org.label-schema.docker.dockerfile="/Dockerfile"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
        g++ \
        gcc \
        libc6-dev \
        make \
        jq \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update

# PIP #

ARG PIP_VERSION_MAGIC=1.5.6-5
RUN apt-get install -y python-pip=${PIP_VERSION_MAGIC}

# end PIP #

# AWS CLI #

ARG AWS_CLI_VERDSION=1.11.57
RUN pip install awscli==${AWS_CLI_VERDSION}

# end AWS CLI #

# NodeJS & NPM #

ARG NODEJS_VERSION_FAMILY=7.x
RUN curl -sL https://deb.nodesource.com/setup_${NODEJS_VERSION_FAMILY} | bash - && apt-get install -y nodejs

# end NodeJS & NPM #

# Severless #

ARG SLS_VERSION=1.8.0
RUN npm install -yg serverless@${SLS_VERSION}

# end Serverless #

# mono #

RUN apt-get update \
  && rm -rf /var/lib/apt/lists/*

ARG MONO_VERSION=4.6.2.16

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/$MONO_VERSION main" | tee /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
  && apt-get update \
  && apt-get install -y mono-complete \
  && rm -rf /var/lib/apt/lists/* /tmp/*
 
# end mono #

# Docker #
RUN apt-get update

RUN apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        software-properties-common

RUN curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -

RUN add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       debian-$(lsb_release -cs) \
       main"

RUN apt-get update

ARG DOCKER_VERSION=1.13.0-0~debian-jessie

RUN apt-get -y install docker-engine=${DOCKER_VERSION}

# Docker end #

# .NET Core #

# dotnet-dev-debian-x64.1.0.0-rc4-004771
ARG NETCORE_URL=https://go.microsoft.com/fwlink/?linkid=841689

RUN apt-get update && apt-get install curl libunwind8 gettext -y
RUN curl -sSL -o /tmp/dotnet.tar.gz ${NETCORE_URL}
RUN mkdir -p /opt/dotnet && tar zxf /tmp/dotnet.tar.gz -C /opt/dotnet
RUN ln -s /opt/dotnet/dotnet /usr/local/bin

# end .NET Core #

COPY start-docker-and-slave /usr/local/bin/start-docker-and-slave

ENTRYPOINT ["start-docker-and-slave"]
