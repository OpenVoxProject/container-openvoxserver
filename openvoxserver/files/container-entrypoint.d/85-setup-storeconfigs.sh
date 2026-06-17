#!/bin/sh

set -e

source /usr/local/share/openvox/config_lib.sh

if [ -n "$OPENVOX_STORECONFIGS_BACKEND" ]; then
  config_set server storeconfigs_backend $OPENVOX_STORECONFIGS_BACKEND
fi

if [ -n "$OPENVOX_STORECONFIGS" ]; then
  config_set server storeconfigs $OPENVOX_STORECONFIGS
fi

if [ -n "$OPENVOX_REPORTS" ]; then
  config_set server reports $OPENVOX_REPORTS
fi

# reset defaults if USE_OPENVOXDB is false, but don't overwrite custom settings
if [ "$USE_OPENVOXDB" = 'false' ]; then
  if [ "$OPENVOX_REPORTS" = 'puppetdb' ]; then
    config_set server reports log
  fi

  if [ "$OPENVOX_STORECONFIGS_BACKEND" = 'puppetdb' ]; then
    config_set server storeconfigs false
  fi
fi
