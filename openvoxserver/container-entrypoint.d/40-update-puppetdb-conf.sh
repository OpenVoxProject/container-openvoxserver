#!/bin/bash

set -e

if test -n "${OPENVOXDB_SERVER_URLS}" ; then
  sed -i "s@^server_urls.*@server_urls = ${OPENVOXDB_SERVER_URLS}@" /etc/puppetlabs/puppet/puppetdb.conf
fi
