#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

if test -n "${OPENVOXDB_SERVER_URLS}"; then
  sed -i "s@^server_urls.*@server_urls = ${OPENVOXDB_SERVER_URLS}@" $(config_get confdir)/puppetdb.conf
fi
