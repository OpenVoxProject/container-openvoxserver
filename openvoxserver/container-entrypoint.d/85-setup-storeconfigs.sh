#!/bin/sh

set -e

if [ -n "$OPENVOX_STORECONFIGS_BACKEND" ]; then
  puppet config set storeconfigs_backend $OPENVOX_STORECONFIGS_BACKEND --section server
fi

if [ -n "$OPENVOX_STORECONFIGS" ]; then
  puppet config set storeconfigs $OPENVOX_STORECONFIGS --section server
fi

if [ -n "$OPENVOX_REPORTS" ]; then
  puppet config set reports $OPENVOX_REPORTS --section server
fi

# reset defaults if USE_OPENVOXDB is false, but don't overwrite custom settings
if [ "$USE_OPENVOXDB" = 'false' ]; then
  if [ "$OPENVOX_REPORTS" = 'puppetdb' ]; then
    puppet config set reports log --section server
  fi

  if [ "$OPENVOX_STORECONFIGS_BACKEND" = 'puppetdb' ]; then
    puppet config set storeconfigs false --section server
  fi
fi
