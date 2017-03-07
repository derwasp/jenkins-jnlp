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

# Python #

ARG PYTHON_PACKAGE_VERSION=3.4.2-2
RUN apt-get install -yV python3=${PYTHON_PACKAGE_VERSION}

# end Python #

# PIP #

ARG PIP_VERSION=1.5.6-5
RUN apt-get install -yV python-pip=${PIP_VERSION}

# end PIP #

# AWS CLI #

ARG AWS_CLI_VERDSION=1.11.57
RUN pip install awscli==${AWS_CLI_VERDSION}

# end AWS CLI #