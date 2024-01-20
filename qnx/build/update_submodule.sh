#!/bin/bash

qnx_submodule() {
    ERROR_MSG="Failed update submodule $1. Please update manually before build"
    cd third_party/$1 || (echo $ERROR_MSG && return 1);
    DIR_B4="$PWD"
    if ! git switch qnx-sdp71-master > /dev/null 2>&1; then
        if ! git switch qnx-sdp71-main > /dev/null 2>&1; then 
            echo "Failed update submodule $1. Please update manually before build"
        fi
    fi
    cd - > /dev/null 2>&1 || (echo $ERROR_MSG && return 1);
    if [ "$DIR_B4" = "$PWD" ]; then
        echo "Error: SOMETHING DIRTY HAPPEND! NOT RETURNING TO THE PROJECT ROOT!"
        exit 1
    fi
}

qnx_submodule "benchmark"

echo "Submodule Updated to QNX Versions!"

# uncomment below when the corresponding repo is ported
# qnx_submodule "abseil-cpp"
# qnx_submodule "boringssl-with-bazel"
# qnx_submodule "googletest"
# qnx_submodule "protobuf"
# qnx_submodule "re2"