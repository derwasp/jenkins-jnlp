FROM jenkinsci/jnlp-slave:3.7-1

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

# mono #

RUN apt-get update \
  && rm -rf /var/lib/apt/lists/*

ARG MONO_VERSION=4.8.0.524

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/$MONO_VERSION main" | tee /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://download.mono-project.com/repo/debian wheezy-apache24-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
  && echo "deb http://download.mono-project.com/repo/debian wheezy-libjpeg62-compat main" | tee -a /etc/apt/sources.list.d/mono-xamarin.list \
  && apt-get update \
  && apt-get install -y mono-complete \
  && rm -rf /var/lib/apt/lists/* /tmp/*

ENV MONO_TLS_PROVIDER=btls

# end mono #

# GitVersion fix - further investigation needed if this can be made prettier #

RUN apt-get update && apt-get install libgit2-dev -y

# GitVersion fix end #

# Zip as override for native packager not being bundled with dotnet

RUN apt-get install zip -y

# End zip hack 

# .NET Core #

RUN apt-get update && apt-get install curl libunwind8 gettext -y
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.asc.gpg && \
    mv microsoft.asc.gpg /etc/apt/trusted.gpg.d/ && \
    wget -q https://packages.microsoft.com/config/debian/8/prod.list && \
    mv prod.list /etc/apt/sources.list.d/microsoft-prod.list
RUN apt-get install -y apt-transport-https
RUN apt-get update
RUN apt-get install dotnet-sdk-2.1.101 -y

# end .NET Core #
