#!/bin/bash
set -e

if [ -n "${EXTERNAL_NODES}" ]; then
  puppet config set external_nodes "$EXTERNAL_NODES" --section server
  puppet config set node_terminus exec --section server
fi
