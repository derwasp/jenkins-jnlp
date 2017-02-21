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

# dotnet-dev-debian-x64.1.0.0-rc4-004771
ARG NETCORE_URL=https://go.microsoft.com/fwlink/?linkid=841689

RUN apt-get update && apt-get install curl libunwind8 gettext -y
RUN curl -sSL -o /tmp/dotnet.tar.gz ${NETCORE_URL}
RUN mkdir -p /opt/dotnet && tar zxf /tmp/dotnet.tar.gz -C /opt/dotnet
RUN ln -s /opt/dotnet/dotnet /usr/local/bin

# end .NET Core #

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