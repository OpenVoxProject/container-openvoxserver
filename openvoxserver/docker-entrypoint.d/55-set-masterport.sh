#!/bin/bash

set -e

hocon() {
  /opt/puppetlabs/puppet/lib/ruby/vendor_gems/bin/hocon "$@"
}

if test -n "$OPENVOXSERVER_PORT"; then
  cd /etc/puppetlabs/puppetserver/conf.d/
  hocon -f webserver.conf set webserver.ssl-port $OPENVOXSERVER_PORT
  cd /
  puppet config set serverport $OPENVOXSERVER_PORT --section main
fi
