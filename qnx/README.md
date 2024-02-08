# Compile The Port for QNX
**NOTE**: QNX ports are only supported from a Linux host operating system

### Common steps:
1. Clone this repository `git clone -b qnx-sdp71-master git@gitlab.rim.net:qnx/osr/grpc.git && cd grpc`
2. We need to manually update submodule to our branch because the information is stored in git database directly and not affected by .gitmodules`git apply ./qnx/qnx_patches/gitmodule.patch && git submodule update --init && ./qnx/build/update_submodule.sh`
3. Setup QNX environment by installing package `com.qnx.qnx710.target.qavf.virtual_socket` from software center and then `source <PATH-TO-SDP>/qnxsdp-env.sh`

### Build with Docker

4. Make sure you have `docker` installed and available on your host machine
5. Run `docker pull ubuntu:22.04` to get the base image
6. Run `cd qnx/build && PROJECT_ROOT=<path_to_project_root> ./docker_build.sh [-m BUILD|CLEAN|DEBUG|INSTALL] [-j <JLEVEL>]`
   * The script will build a docker image named `grpc_build`
   * Your SDP path and the project root will be mounted to the container, so all output
   * You should see the building process in your terminal as the contrainer is attached.
   * There are four modes available in the build script:
     * `BUILD`: Default option. build the image and launch docker container and build the project, output to the mounted project `qnx/build/`
     * `INSTALL`: same as `BUILD`, but also install the output file to the QNX SDP environment that user sourced at step 3.
     * `DEBUG`: simply build the image and launch the container with mounted files. User can build single files in the container
     * `CLEAN`: clean the build

### Buid on Your Host Machine
4. Run the following commands to setup the environment on your host
    ```
    # Build and install grpc for the host first
    apt-get update
    apt-get install -y git protobuf-compiler
    apt-get install -y build-essential autoconf libtool pkg-config
    apt-get install -y clang libc++-dev
    # This is necessary: install a host grpc first!
    mkdir -p cmake/build && cd cmake/build && cmake ../.. && make -j8 install
    ```
5. Run `[JLEVEL=<JLEVEL>] make -C qnx/build install` to build and install the project to your SDP path. `JLEVEL` is similar to the `-j` option of `make`, but please use `JLEVEL` instead.

### Others
* `gitmodule_ideal.patch` should not be used until all dependent repos are ported.