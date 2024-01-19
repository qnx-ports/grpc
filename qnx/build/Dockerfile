FROM ubuntu:22.04

ARG SDP_PATH
ARG GRPC_VER
ENV SDP_PATH=$SDP_PATH

ARG UNAME=testuser
ARG UID
ARG GID

RUN apt update && apt install -y wget curl &&\
    echo "Installing cmake3.18" &&\
    wget https://cmake.org/files/v3.18/cmake-3.18.0-Linux-x86_64.sh &&\
    sh cmake-3.18.0-Linux-x86_64.sh --prefix=/usr/local --skip-license &&\
    cmake --version &&\
    echo 'Etc/UTC' > /etc/timezone &&\
    ln -s /usr/share/zoneinfo/Etc/UTC /etc/localtime &&\
    apt-get update &&\
    apt-get install -q -y --no-install-recommends tzdata locales gnupg2 &&\
    locale-gen ${LANG}; dpkg-reconfigure -f noninteractive locales &&\
    apt-get install -y --no-install-recommends  git protobuf-compiler build-essential autoconf libtool pkg-config clang libc++-dev

RUN git clone -b ${GRPC_VER} https://github.com/grpc/grpc ~/linux_grpc &&\
    cd ~/linux_grpc &&\
    git submodule update --init &&\
    mkdir -p cmake/build && cd cmake/build && cmake ../.. && make -j8 install

# add -l to avoid long-time exporting layer 
# https://stackoverflow.com/questions/73208471/docker-build-issue-stuck-at-exporting-layers
RUN groupadd -g $GID -o $UNAME && useradd -m -l -u $UID -g $GID -o -s /bin/bash $UNAME
USER $UNAME
