#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
set -euo pipefail

if [ ! -d 'uboot_v2021_04' ]; then
  git clone --depth 1 --filter=blob:none --recurse-submodules -j"$(nproc)" --remote-submodules 'https://source.denx.de/u-boot/u-boot.git' -b 'v2021.04' 'uboot_v2021_04'
fi

if [ ! -d 'odroidg12' ]; then
  git clone --depth 1 --filter=blob:none --recurse-submodules -j"$(nproc)" --remote-submodules 'https://github.com/hardkernel/u-boot.git' -b 'odroidg12-v2015.01' 'odroidg12'
fi

if [ ! -d 'amlogic-boot-fip' ]; then
  git clone --depth 1 --filter=blob:none --recurse-submodules -j"$(nproc)" --remote-submodules 'https://github.com/LibreELEC/amlogic-boot-fip' 'amlogic-boot-fip'
fi

if [ ! -f 'gcc-linaro-aarch64-none-elf_linux.tar.xz' ]; then
  wget -O 'gcc-linaro-aarch64-none-elf_linux.tar.xz' 'https://releases.linaro.org/archive/13.11/components/toolchain/binaries/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux.tar.xz'
fi

if [ ! -f 'gcc-linaro-arm-none-eabi.tar.xz' ]; then
  wget -O 'gcc-linaro-arm-none-eabi.tar.xz' 'https://releases.linaro.org/archive/13.11/components/toolchain/binaries/gcc-linaro-arm-none-eabi-4.8-2013.11_linux.tar.xz'
fi
