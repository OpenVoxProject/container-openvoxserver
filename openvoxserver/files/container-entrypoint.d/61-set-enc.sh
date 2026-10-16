#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

if [ -n "${EXTERNAL_NODES}" ]; then
  config_set server external_nodes "$EXTERNAL_NODES" node_terminus exec
fi
