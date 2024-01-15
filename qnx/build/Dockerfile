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
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 &&\
    echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu focal main" > /etc/apt/sources.list.d/ros2-latest.list

USER root

RUN apt-get update && \
    apt-get install -y git protobuf-compiler && \
    apt-get install -y build-essential autoconf libtool pkg-config && \
    apt-get install -y clang libc++-dev &&\
    git clone -b ${GRPC_VER} https://github.com/grpc/grpc /builds/workspace/grpc &&\
    cd /builds/workspace/grpc &&\
    git submodule update --init &&\
    mkdir -p cmake/build && cd cmake/build && cmake ../.. && make -j8 install

RUN groupadd -g $GID -o $UNAME
RUN useradd -m -u $UID -g $GID -o -s /bin/bash $UNAME
USER $UNAME