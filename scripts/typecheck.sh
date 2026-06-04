#!/usr/bin/env bash
# Type-check the single-file PEP 723 script with Astral's `ty`.
#
# `ty` needs the script's third-party deps resolvable. They live in the
# PEP 723 inline metadata (the single source of truth), so export them and
# inject them into ty's ephemeral tool env via --with-requirements.
set -euo pipefail
cd "$(dirname "$0")/.."

reqs="$(mktemp)"
trap 'rm -f "$reqs"' EXIT

uv export --script outline --quiet -o "$reqs"
uvx --with-requirements "$reqs" ty check outline
