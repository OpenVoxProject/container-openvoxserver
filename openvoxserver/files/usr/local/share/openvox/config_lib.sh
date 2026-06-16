#!/bin/bash
# Helper script to avoid `puppet config` calls, as each invocation takes time and adds up.
# See /usr/local/bin/config_ini.rb for the INI manipulation logic.
# We have to reference a file instead of environment variables because the output of any
# `set` command would otherwise be lost in the sequence (ie 50-* cannot be sourced by 70-*)

# Put the cache under /run so it's recreated every container start
OPENVOX_CONFIG_CACHE=/run/openvox/config-lib-cache

# Check if the above cache exists. If not, create and populate it.
config_load() {
  [ -s "$OPENVOX_CONFIG_CACHE" ] && return 0
  mkdir -p "${OPENVOX_CONFIG_CACHE%/*}"
  puppet config print \
    confdir ssldir cadir certname csr_attributes dns_alt_names \
    hostcert hostprivkey localcacert hostcrl cacert \
    >"$OPENVOX_CONFIG_CACHE"
}

# We now have a file with key pair values. Take in an argument, use sed to
# substitute (s/) the parameter ($1 =) with nothing (//) and print (p) the remainder of the line.
config_get() {
  config_load
  sed -n "s/^$1 = //p" "$OPENVOX_CONFIG_CACHE"
}

config_set() {
  /usr/local/bin/config_ini.rb set "$@"
}

config_delete() {
  /usr/local/bin/config_ini.rb delete "$@"
}
