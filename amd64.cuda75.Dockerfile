FROM nvidia/cuda:7.5-cudnn6-devel

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    curl \
    git \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:ubuntu-toolchain-r/test \
    && apt-get update && apt-get install -y --no-install-recommends --no-install-suggests \
    g++-4.9 \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 30 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 30 \
    && update-alternatives --set gcc /usr/bin/gcc-4.9 \
    && update-alternatives --set g++ /usr/bin/g++-4.9

RUN gcc --version
RUN g++ --version

RUN curl -sSL https://cmake.org/files/v3.12/cmake-3.12.1-Linux-x86_64.tar.gz -o cmake.tar.gz \
    && tar -xf cmake.tar.gz \
    && cp -r cmake-3.12.1-Linux-x86_64/* /usr/. \
    && rm cmake.tar.gz

RUN cmake --version

ENV SCOPE_ROOT /opt/scope
COPY . ${SCOPE_ROOT}
WORKDIR ${SCOPE_ROOT}

RUN mkdir -p build \
    && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_MISC=OFF \
    -DENABLE_NCCL=OFF \
    -DENABLE_CUDNN=OFF \
    -DENABLE_COMM=OFF \
    -DNVCC_ARCH_FLAGS="2.0 3.0 3.2 3.5 3.7 5.0 5.2 5.3" \
    && make VERBOSE=1

ENV PATH ${SCOPE_ROOT}/build:$PATH
