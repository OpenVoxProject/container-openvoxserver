#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

if [ -n "$OPENVOXSERVER_ENVIRONMENT_TIMEOUT" ]; then
  echo "Settings environment_timeout to ${OPENVOXSERVER_ENVIRONMENT_TIMEOUT}"
  config_set server environment_timeout $OPENVOXSERVER_ENVIRONMENT_TIMEOUT
else
  echo "Removing environment_timeout"
  config_delete server environment_timeout
fi
