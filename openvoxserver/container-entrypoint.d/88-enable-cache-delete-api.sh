#!/bin/bash

set -e

# determine script location
readonly SCRIPT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
readonly SCRIPT_PATH=$(dirname "$SCRIPT_FILENAME")

if [[ "$OPENVOXSERVER_ENABLE_ENV_CACHE_DEL_API" == true ]]; then
  if [[ $(grep 'puppet-admin-api' /etc/puppetlabs/puppetserver/conf.d/auth.conf) ]]; then
    echo "Admin API already set"
  else
    /opt/puppetlabs/puppet/bin/ruby "$SCRIPT_PATH/88-add_cache_del_api_auth_rules.rb"
  fi
fi
