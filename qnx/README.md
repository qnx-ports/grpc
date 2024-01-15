# Compile The Port for QNX
**NOTE**: QNX ports are only supported from a Linux host operating system

### Build with Docker
1. Clone this repository `git clone -b qnx-sdp71-master git@gitlab.rim.net:qnx/osr/grpc.git`
2. Make sure you have `docker` installed and available on your host machine
3. Run `docker pull ubuntu:22.04` to get the base image
4. Setup QNX environment by `source <PATH-TO-SDP>/qnxsdp-env.sh`
5. Run `cd qnx/build && PROJECT_ROOT=[path_to_project_root] ./docker_build.sh [-m BUILD|CLEAN|DEBUG|INSTALL] [-j JLEVEL]`
   * The script will build a docker image named `grpc_build`
   * Your SDP path and the project root will be mounted to the container, so all output
   * You should see the building process in your terminal as the contrainer is attached.
   * There are four modes available in the build script:
     * `BUILD`: Default option. build the image and launch docker container and build the project, output to the mounted project `qnx/build/`
     * `INSTALL`: same as `BUILD`, but also install the output file to the QNX SDP environment that user sourced at step 3.
     * `DEBUG`: simply build the image and launch the container with mounted files. User can build single files in the container
     * `CLEAN`: clean the build

### Buid on Your Host Machine
1. Clone this repository `git clone -b qnx-sdp71-master git@gitlab.rim.net:qnx/osr/grpc.git`
2. `cd grpc && git apply ./qnx/build/qnx_patches/gitmodule.patch`
3. Run the following commands to setup the environment on your host
    ```
    # Build and install grpc for the host first
    apt-get update
    apt-get install -y git protobuf-compiler
    apt-get install -y build-essential autoconf libtool pkg-config
    apt-get install -y clang libc++-dev
    git submodule update --init
    mkdir -p cmake/build && cd cmake/build && cmake ../.. && make -j8 install
    ```
4. Setup QNX environment by `source <PATH-TO-SDP>/qnxsdp-env.sh`
5. Run `JLEVEL=[JLEVEL] make -C qnx/build install` to build and install the project to your SDP path. `JLEVEL` is similar to the `-j` option of `make`, but please use `JLEVEL` instead.