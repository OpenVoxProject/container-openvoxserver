#!/bin/bash

set -e

if [ -n "${OPENVOXSERVER_HOSTNAME}" ]; then
  puppet config set server "$OPENVOXSERVER_HOSTNAME"
fi

if [ -n "${CERTNAME}" ]; then
  puppet config set certname "$CERTNAME"
fi
