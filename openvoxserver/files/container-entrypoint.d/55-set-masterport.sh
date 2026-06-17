#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

if test -n "$OPENVOXSERVER_PORT"; then
  cd /etc/puppetlabs/puppetserver/conf.d/
  hocon -f webserver.conf set webserver.ssl-port $OPENVOXSERVER_PORT
  cd /
  config_set main serverport $OPENVOXSERVER_PORT
fi
