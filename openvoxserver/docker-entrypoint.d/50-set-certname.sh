#!/bin/bash

set -e

if [ -n "${OPENVOXSERVER_HOSTNAME}" ]; then
  /usr/bin/puppet config set server "$OPENVOXSERVER_HOSTNAME"
fi

if [ -n "${CERTNAME}" ]; then
  /usr/bin/puppet config set certname "$CERTNAME"
fi
