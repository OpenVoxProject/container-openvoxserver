#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

config_set main \
  confdir /etc/puppetlabs/puppet \
  vardir /opt/puppetlabs/puppet/cache \
  logdir /var/log/puppetlabs/puppet \
  codedir /etc/puppetlabs/code \
  rundir /var/run/puppetlabs \
  manage_internal_file_permissions false
