#!/usr/bin/env bash

set -x
set -e

source /usr/local/share/openvox/config_lib.sh

timeout=10

if [ "$#" -gt 0 ]; then
  timeout=$1
fi

curl --fail \
  --no-progress-meter \
  --max-time ${timeout} \
  --resolve "${HOSTNAME}:${OPENVOXSERVER_PORT:-8140}:127.0.0.1" \
  --cert $(config_get hostcert) \
  --key $(config_get hostprivkey) \
  --cacert $(config_get localcacert) \
  "https://${HOSTNAME}:${OPENVOXSERVER_PORT:-8140}/status/v1/simple" |
  grep -q '^running$' ||
  exit 1
