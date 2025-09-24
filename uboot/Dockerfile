FROM debian

# OS dependencies
# Ref: https://docs.u-boot.org/en/stable/build/gcc.html#debian-based
ENV DEBIAN_FRONTEND=noninteractive
RUN --mount=target=/var/lib/apt/lists,type=cache,sharing=locked \
    --mount=target=/var/cache/apt,type=cache,sharing=locked \
    rm -f /etc/apt/apt.conf.d/docker-clean && \
    dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -y -qq ca-certificates gnupg dirmngr && \
    add-apt-repository -y universe || true && \
    apt-get update -qq && \
    apt-get install -y -qq \
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
      zlib1g zlib1g:i386 \
      libgnutls28-dev libgnutls28-dev:i386 pkg-config \
      ccache \
      rsync \
;

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

WORKDIR /work/fip
RUN set -eux \
    && mkdir -p fip \
    # Download the blx_fix script into the fip/ directory \
    && wget -O fip/blx_fix.sh 'https://github.com/BayLibre/u-boot/releases/download/v2017.11-libretech-cc/blx_fix_g12a.sh' \
    && chmod +x fip/blx_fix.sh \
    # Copy required artifacts from the built U-Boot tree into fip/ \
    && cp "$UBOOTDIR/build/scp_task/bl301.bin" fip/ \
    && cp "$UBOOTDIR/build/board/hardkernel/odroidc4/firmware/acs.bin" fip/ \
    && cp "$UBOOTDIR/fip/g12a/bl2.bin" fip/ \
    && cp "$UBOOTDIR/fip/g12a/bl30.bin" fip/ \
    && cp "$UBOOTDIR/fip/g12a/bl31.img" fip/ \
    && cp "$UBOOTDIR/fip/g12a/ddr3_1d.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/ddr4_1d.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/ddr4_2d.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/diag_lpddr4.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/lpddr3_1d.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/lpddr4_1d.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/lpddr4_2d.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/piei.fw" fip/ \
    && cp "$UBOOTDIR/fip/g12a/aml_ddr.fw" fip/ \
    && cp /work/u-boot/u-boot.bin fip/bl33.bin \
    # Run the blx_fix transformations (bl30 and bl2 flows) \
    && sh fip/blx_fix.sh \
         fip/bl30.bin \
         fip/zero_tmp \
         fip/bl30_zero.bin \
         fip/bl301.bin \
         fip/bl301_zero.bin \
         fip/bl30_new.bin \
         bl30 \
    && sh fip/blx_fix.sh \
         fip/bl2.bin \
         fip/zero_tmp \
         fip/bl2_zero.bin \
         fip/acs.bin \
         fip/bl21_zero.bin \
         fip/bl2_new.bin \
         bl2 \
    # Run the aml_encrypt_g12a tools from the UBOOTDIR fip/g12a tree \
    && "$UBOOTDIR/fip/g12a/aml_encrypt_g12a" --bl30sig --input fip/bl30_new.bin \
                                       --output fip/bl30_new.bin.g12a.enc \
                                       --level v3 \
    && "$UBOOTDIR/fip/g12a/aml_encrypt_g12a" --bl3sig --input fip/bl30_new.bin.g12a.enc \
                                       --output fip/bl30_new.bin.enc \
                                       --level v3 --type bl30 \
    && "$UBOOTDIR/fip/g12a/aml_encrypt_g12a" --bl3sig --input fip/bl31.img \
                                       --output fip/bl31.img.enc \
                                       --level v3 --type bl31 \
    && "$UBOOTDIR/fip/g12a/aml_encrypt_g12a" --bl3sig --input fip/bl33.bin --compress lz4 \
                                       --output fip/bl33.bin.enc \
                                       --level v3 --type bl33 --compress lz4 \
    && "$UBOOTDIR/fip/g12a/aml_encrypt_g12a" --bl2sig --input fip/bl2_new.bin \
                                       --output fip/bl2.n.bin.sig \
    && "$UBOOTDIR/fip/g12a/aml_encrypt_g12a" --bootmk \
                                       --output fip/u-boot.bin \
                                       --bl2 fip/bl2.n.bin.sig \
                                       --bl30 fip/bl30_new.bin.enc \
                                       --bl31 fip/bl31.img.enc \
                                       --bl33 fip/bl33.bin.enc \
                                       --ddrfw1 fip/ddr4_1d.fw \
                                       --ddrfw2 fip/ddr4_2d.fw \
                                       --ddrfw3 fip/ddr3_1d.fw \
                                       --ddrfw4 fip/piei.fw \
                                       --ddrfw5 fip/lpddr4_1d.fw \
                                       --ddrfw6 fip/lpddr4_2d.fw \
                                       --ddrfw7 fip/diag_lpddr4.fw \
                                       --ddrfw8 fip/aml_ddr.fw \
                                       --ddrfw9 fip/lpddr3_1d.fw \
                                       --level v3
