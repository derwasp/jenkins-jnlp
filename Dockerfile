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
