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

# .NET Core #

# dotnet-dev-debian-x64.1.0.1
ARG NETCORE_URL=https://go.microsoft.com/fwlink/?LinkID=843453

RUN apt-get update && apt-get install curl libunwind8 gettext -y
RUN curl -sSL -o /tmp/dotnet.tar.gz ${NETCORE_URL}
RUN mkdir -p /opt/dotnet && tar zxf /tmp/dotnet.tar.gz -C /opt/dotnet
RUN ln -s /opt/dotnet/dotnet /usr/local/bin

# end .NET Core #