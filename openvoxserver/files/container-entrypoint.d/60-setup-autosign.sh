#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

# Configure puppet to use a certificate autosign script (if it exists)
# AUTOSIGN=true|false|path_to_autosign.conf
if test -n "${AUTOSIGN}"; then
  config_set server autosign "$AUTOSIGN"
fi
