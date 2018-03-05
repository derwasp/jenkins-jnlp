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

RUN apt-get update && apt-get install libssl-dev cmake -y
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

# dotnet-dev-debian-x64.1.0.4
ARG NETCORE_URL=https://download.microsoft.com/download/E/7/8/E782433E-7737-4E6C-BFBF-290A0A81C3D7/dotnet-dev-debian-x64.1.0.4.tar.gz

RUN apt-get update && apt-get install curl libunwind8 gettext -y
RUN curl -sSL -o /tmp/dotnet.tar.gz ${NETCORE_URL}
RUN mkdir -p /opt/dotnet && tar zxf /tmp/dotnet.tar.gz -C /opt/dotnet
RUN ln -s /opt/dotnet/dotnet /usr/local/bin

# end .NET Core #
