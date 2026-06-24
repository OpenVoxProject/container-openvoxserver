#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

if [ -n "${OPENVOXSERVER_HOSTNAME}" ]; then
  config_set main server "$OPENVOXSERVER_HOSTNAME"
fi

if [ -n "${CERTNAME}" ]; then
  config_set main certname "$CERTNAME"
fi
