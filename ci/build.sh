#! /bin/bash

set -x

function or_die () {
    "$@"
    local status=$?
    if [[ $status != 0 ]] ; then
        echo ERROR $status command: $@
        exit $status
    fi
}

source ~/.bashrc

if [[ $DO_BUILD == 1 ]]; then
    cd ${TRAVIS_BUILD_DIR}
    or_die mkdir -p build && cd build
    or_die cmake \
        -DCONFIG_USE_HUNTER=${USE_HUNTER} \
        -DCONFIG_USE_TRAVIS=ON \
        -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER} \
        -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER} \
        -DENABLE_MISC=0 \
        -DENABLE_NCCL=0 \
        -DENABLE_COMM=0 \
        -DENABLE_CUDNN=0 \
        ..
    or_die make
fi

set +x
exit 0
