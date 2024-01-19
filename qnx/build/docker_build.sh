#!/bin/bash
if [ -z "$QNX_TARGET" ]; then
    echo 'Error: QNX must be specified. Please source your qnxsdp-env'
    exit 1
fi

usage() {
  echo "Usage: docker_build.sh [-m BUILD|INSTALL|CLEAN|DEBUG]"
  echo "Description:"
  echo "-m: set the docker running mode. If not specified, default to BUILD"
  echo "  BUILD: do a build by docker."
  echo "  INSTALL: build by docker and install output to the mounted SDP path."
  echo "  CLEAN: clean the build by docker."
  echo "  DEBUG: lauch the docker image in bash"
  echo "-j: set the JLEVEL when building the project"
  exit 0
}

IMAGE_NAME="grpc_build"
MODE="BUILD"
JLEVEL=4
while getopts 'm:j:h' OPT; do
  case $OPT in
    m) MODE="$OPTARG";;
    j) JLEVEL=$OPTARG;;
    h) usage;;
    ?) usage;;
  esac
done

if [ -z "$PROJECT_ROOT" ]; then
  echo 'Error: Please specify the project root path by PROJECT_ROOT=[path_to_root]'
  exit 1
fi

USERNAME=$(whoami)

UHOME="$(realpath ~)"
# MOUNT_PATH="$UHOME/grpc_build"
MOUNT_PATH="$(realpath $PROJECT_ROOT)"
# BUILD_PATH="$MOUNT_PATH/qnx/build"
BUILD_PATH="$MOUNT_PATH/qnx/build"
# DOCKER_PATH="$PROJECT_ROOT/qnx/build"
SDP_PATH=$(realpath "$QNX_TARGET/../../")
# SDP_DEST="$UHOME/sdp"

BASH_CMD='bash -i -c'
SOURCE_CMD="source \$SDP_PATH/qnxsdp-env.sh"
ENTRY_CMD=''
if [ $MODE = "DEBUG" ]; then
  ENTRY_CMD="bash"
elif [ $MODE = "CLEAN" ]; then
  MAKE_CMD="JLEVEL=$JLEVEL make -C $BUILD_PATH clean"
elif [ $MODE = "BUILD" ]; then
  MAKE_CMD="JLEVEL=$JLEVEL make -C $BUILD_PATH all"
elif [ $MODE = "INSTALL" ]; then
  MAKE_CMD="JLEVEL=$JLEVEL make -C $BUILD_PATH install"
else
  echo "invalid option args"
  usage
  exit 1
fi

if [ -z $ENTRY_CMD ]; then
  ENTRY_CMD="$BASH_CMD '$SOURCE_CMD && $MAKE_CMD'"
fi
echo $ENTRY_CMD

docker build \
    --build-arg UNAME=$USERNAME \
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    --build-arg="SDP_PATH=$SDP_PATH" \
    --build-arg="GRPC_VER=v1.59.1" \
    -t $IMAGE_NAME $BUILD_PATH

if [ $? -ne 0 ]; then
  echo "docker build failed"
  exit 1
fi

eval docker run -it \
    -v "$SDP_PATH:$SDP_PATH" \
    -v "$MOUNT_PATH:$MOUNT_PATH" \
    -v ~/.qnx/:$UHOME/.qnx/ \
    -v "$(dirname "$SSH_AUTH_SOCK")" \
    --env SSH_AUTH_SOCK="$SSH_AUTH_SOCK" \
    $IMAGE_NAME $ENTRY_CMD