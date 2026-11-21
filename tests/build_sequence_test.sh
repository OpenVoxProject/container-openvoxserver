#!/bin/bash
#
# Tests for build_sequence.sh. Needs bash and jq; no registry access.
# Run from anywhere: bash tests/build_sequence_test.sh

set -euo pipefail

script="$(cd "$(dirname "$0")/.." && pwd)/build_sequence.sh"
workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

failures=0

# check NAME EXPECTED TAGS_JSON VERSION...
check() {
  local name=$1 expected=$2 tags=$3
  shift 3
  local actual
  printf '%s' "$tags" > "$workdir/tags.json"
  if ! actual=$(bash "$script" --tags "$workdir/tags.json" "$@" 2>"$workdir/stderr"); then
    echo "FAIL: $name: exited non-zero: $(cat "$workdir/stderr")"
    failures=$((failures + 1))
  elif [ "$actual" != "$expected" ]; then
    echo "FAIL: $name: expected $expected, got $actual"
    failures=$((failures + 1))
  else
    echo "ok: $name"
  fi
}

# check_fails NAME TAGS_JSON VERSION...
check_fails() {
  local name=$1 tags=$2
  shift 2
  printf '%s' "$tags" > "$workdir/tags.json"
  if bash "$script" --tags "$workdir/tags.json" "$@" >/dev/null 2>&1; then
    echo "FAIL: $name: expected a non-zero exit"
    failures=$((failures + 1))
  else
    echo "ok: $name"
  fi
}

check "empty registry starts at 0" \
  '{"8.18.0":0}' \
  '{"Tags":[]}' 8.18.0

check "legacy -main and -vX.Y.Z tags are ignored" \
  '{"8.18.0":0}' \
  '{"Tags":["8.18.0","8.18.0-alpine","8.18.0-main","8.18.0-main-alpine","8.18.0-v1.2.3","8.18.0-v1.2.3-alpine","8","latest"]}' 8.18.0

check "next number follows the highest" \
  '{"8.18.0":2}' \
  '{"Tags":["8.18.0-0","8.18.0-0-alpine","8.18.0-1","8.18.0-1-alpine"]}' 8.18.0

check "numbers compare numerically, not as strings" \
  '{"8.18.0":11}' \
  '{"Tags":["8.18.0-9","8.18.0-10","8.18.0-2"]}' 8.18.0

check "an Alpine-only number is not reused" \
  '{"8.18.0":4}' \
  '{"Tags":["8.18.0-2","8.18.0-3-alpine"]}' 8.18.0

check "other versions and per-commit tags are ignored" \
  '{"8.18.0":1}' \
  '{"Tags":["8.18.0-0","8.18.1-7","8.18.01-5","18.18.0-6","8-0123abc-ubuntu-amd64","8.18.0-5-ubuntu-amd64"]}' 8.18.0

check "dots in the version are not regex wildcards" \
  '{"8.18.0":0}' \
  '{"Tags":["8x18y0-5","8.18.0x-3"]}' 8.18.0

check "each version is numbered independently" \
  '{"8.18.0":2,"9.2.0":0}' \
  '{"Tags":["8.18.0-1","9.1.0-4"]}' 8.18.0 9.2.0

check_fails "malformed JSON fails instead of returning 0" \
  '{"Tags":' 8.18.0

check_fails "a listing without .Tags fails instead of returning 0" \
  '{"Repository":"ghcr.io/openvoxproject/openvoxserver"}' 8.18.0

if [ "$failures" -ne 0 ]; then
  echo "$failures test(s) failed"
  exit 1
fi
echo "all tests passed"
