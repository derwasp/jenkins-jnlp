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

ARG DOCKER_VERSION=1.13.1-0~debian-jessie

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
