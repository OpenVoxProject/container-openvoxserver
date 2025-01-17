#!/bin/bash

set -e

if [ -n "$OPENVOXSERVER_ENVIRONMENT_TIMEOUT" ]; then
  echo "Settings environment_timeout to ${OPENVOXSERVER_ENVIRONMENT_TIMEOUT}"
  puppet config set --section server environment_timeout $OPENVOXSERVER_ENVIRONMENT_TIMEOUT
else
  echo "Removing environment_timeout"
  puppet config delete --section server environment_timeout
fi
