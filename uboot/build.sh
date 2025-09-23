#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
set -euo pipefail

echo 123
export CROSS_COMPILE=aarch64-none-elf-
make odroid-c4_defconfig