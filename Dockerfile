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
ARG DOCKER_VERSION=1.13.0-0

RUN RELEASE=${DOCKER_VERSION}~debian-$(lsb_release -cs) && \
            apt-get -y install docker-engine=$RELEASE

# Docker end #

# GitVersion fix - further investigation needed if this can be made prettier #

RUN apt-get install libssl-dev cmake -y
RUN mkdir tempBuild

RUN git clone https://github.com/libgit2/libgit2 tempBuild
RUN cd tempBuild && mkdir build && cd build
WORKDIR tempBuild/build
RUN cmake ..
RUN cmake --build .
RUN mkdir /lib/linux && mkdir /lib/linux/x86_64 && cp /home/jenkins/tempBuild/build/*.* /lib/linux/x86_64
# The name of the file is as referenced by GitVersion.CommandLine (3.6.5) - there may be a better way to do this
RUN mv /lib/linux/x86_64/libgit2.so /lib/linux/x86_64/libgit2-baa87df.so
RUN rm tempBuild -rf
WORKDIR /

# GitVersion fix end #

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
