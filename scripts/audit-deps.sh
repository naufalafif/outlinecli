#!/usr/bin/env bash
# Audit the script's dependencies for known CVEs with pip-audit.
#
# Deps come from the PEP 723 inline metadata via `uv export` (single source
# of truth). The export is fully pinned, so `--no-deps --disable-pip` audits
# it directly without building a resolution venv — which avoids the broken
# `ensurepip` on uv-managed standalone Python.
set -euo pipefail
cd "$(dirname "$0")/.."

reqs="$(mktemp)"
trap 'rm -f "$reqs"' EXIT

uv export --script outline --quiet -o "$reqs"
uvx pip-audit -r "$reqs" --no-deps --disable-pip --progress-spinner off
