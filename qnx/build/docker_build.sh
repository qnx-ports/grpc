#!/bin/bash
if [ -z "$QNX_TARGET" ]; then
    echo 'Error: QNX must be specified. Please source your qnxsdp-env'
    exit 1
fi

SDP_PATH=$(realpath "$QNX_TARGET"/../../)
SDP_DEST="/root/sdp"


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

BUILD_PATH="/root/workspace/qnx/build"
IMAGE_NAME="docker_build"
MODE="BUILD"
JLEVEL=1
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
    --build-arg UID=$(id -u) \
    --build-arg GID=$(id -g) \
    --build-arg="SDP_PATH=$SDP_DEST" \
    --build-arg="GRPC_VER=v1.59.1" \
    -t $IMAGE_NAME .

eval docker run -it \
    -v "$SDP_PATH:$SDP_DEST" \
    -v "$(realpath $PROJECT_ROOT):/root/workspace" \
    -v ~/.qnx/:/root/.qnx/ \
    -v "$(dirname "$SSH_AUTH_SOCK"):$(dirname "$SSH_AUTH_SOCK")" \
    --env SSH_AUTH_SOCK="$SSH_AUTH_SOCK" \
    $IMAGE_NAME $ENTRY_CMD