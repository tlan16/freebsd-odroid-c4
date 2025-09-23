FROM debian

# OS dependencies
# Ref: https://docs.u-boot.org/en/stable/build/gcc.html#debian-based
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -y -qq \
      gcc gcc-aarch64-linux-gnu \
      bc bison build-essential coccinelle \
      device-tree-compiler dfu-util efitools flex gdisk graphviz imagemagick \
      libgnutls28-dev libguestfs-tools libncurses-dev \
      libpython3-dev libsdl2-dev libssl-dev lz4 lzma lzma-alone openssl \
      pkg-config python3 python3-asteval python3-coverage python3-filelock \
      python3-pkg-resources python3-pycryptodome python3-pyelftools \
      python3-pytest python3-pytest-xdist python3-sphinxcontrib.apidoc \
      python3-sphinx-rtd-theme python3-subunit python3-testtools \
      python3-venv swig uuid-dev \
      zlib1g zlib1g-dev \
      ccache \
      libc6:i386 libstdc++6:i386 \
      qemu-user-static binfmt-support

ENV CCACHE_DIR=/ccache

# Setup ccache
RUN for p in gcc g++ cc c++; do ln -vs /usr/bin/ccache /usr/local/bin/$p;  done

# U-Boot Compilation
# Ref: https://docs.u-boot.org/en/stable/board/amlogic/odroid-c4.html#u-boot-compilation
ENV CROSS_COMPILE=aarch64-linux-gnu-
WORKDIR /work/u-boot/
COPY uboot_master/ ./
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make odroid-c4_defconfig
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make -j$(nproc)

# U-Boot Signing with Pre-Built FIP repo
# Ref: https://docs.u-boot.org/en/stable/board/amlogic/odroid-c4.html#u-boot-signing-with-pre-built-fip-repo
WORKDIR /work/amlogic-boot-fip/
COPY amlogic-boot-fip/ ./
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  mkdir my-output-dir \
  && ./build-fip.sh odroid-c4 /work/u-boot/u-boot.bin my-output-dir

# U-Boot Manual Signing
# Ref: https://docs.u-boot.org/en/stable/board/amlogic/odroid-c4.html#u-boot-manual-signing
WORKDIR /work/manual-signing/
COPY gcc-linaro-aarch64-none-elf_linux.tar.xz .
COPY gcc-linaro-arm-none-eabi.tar.xz .
RUN tar xvfJ gcc-linaro-aarch64-none-elf_linux.tar.xz
RUN tar xvfJ gcc-linaro-arm-none-eabi.tar.xz
ENV PATH="/work/manual-signing/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux/bin:/work/manual-signing/gcc-linaro-arm-none-eabi-4.8-2013.11_linux/bin:$PATH"

WORKDIR /work/manual-signing/odroid-c4
COPY odroidg12/ ./
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make odroidc4_defconfig
RUN --mount=type=cache,target=/ccache/,sharing=locked \
  make -j$(nproc)
ENV UBOOTDIR=/work/manual-signing/odroid-c4
