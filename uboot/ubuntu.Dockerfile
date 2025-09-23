FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends software-properties-common ca-certificates gnupg dirmngr && \
    add-apt-repository -y universe || true && \
    apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
      build-essential \
      ca-certificates \
      git \
      bc \
      bison \
      flex \
      swig \
      python3 \
      python3-dev \
      libssl-dev \
      device-tree-compiler \
      wget \
      curl \
      u-boot-tools \
      gdisk \
      parted \
      xz-utils \
      gcc-aarch64-linux-gnu \
      binutils-aarch64-linux-gnu \
      ccache && \
    rm -rf /var/lib/apt/lists/*

ENV CROSS_COMPILE=aarch64-linux-gnu-

# Configure ccache: cache directory and max size
ENV CCACHE_DIR=/ccache
ENV CCACHE_MAXSIZE=5G
RUN --mount=type=cache,target=/ccache/,sharing=locked \
    mkdir -p $CCACHE_DIR && \
    chown -R root:root $CCACHE_DIR && \
    ccache -M $CCACHE_MAXSIZE || true && \
    ccache -s || true && \
    mkdir -p /usr/local/bin && \
    ln -sf /usr/bin/ccache /usr/local/bin/gcc && \
    ln -sf /usr/bin/ccache /usr/local/bin/g++ && \
    ln -sf /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-gcc && \
    ln -sf /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-g++

WORKDIR /work
RUN git clone --depth 1 https://source.denx.de/u-boot/u-boot.git -b v2021.04
WORKDIR /work/u-boot
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make odroid-c4_defconfig
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make -j$(nproc)

WORKDIR /work
RUN git clone --depth 1 https://github.com/hardkernel/u-boot.git -b odroidg12-v2015.01 odroid-c4-vendor
WORKDIR /work/odroid-c4-vendor
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make odroidc4_defconfig
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make -j$(nproc)
ENV UBOOTDIR=/work/odroid-c4-vendor
