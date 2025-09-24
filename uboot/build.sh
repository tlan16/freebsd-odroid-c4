#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1
set -euo pipefail

rm -rf dist/* dist/.* 2>/dev/null || true
docker compose run --rm --build app rsync -avh /work/fip/fip/ /dist/
ls -alh dist
