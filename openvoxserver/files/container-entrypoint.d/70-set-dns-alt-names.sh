#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

config_section=main

# Allow setting dns_alt_names for the compilers certificate. This
# setting will only have an effect when the container is started without
# an existing certificate on the /etc/puppetlabs/puppet volume
if [ -n "${DNS_ALT_NAMES}" ]; then
  certname=$(config_get certname)
  if test ! -f "$(config_get ssldir)/certs/$certname.pem"; then
    config_set "${config_section}" dns_alt_names "${DNS_ALT_NAMES}"
  else
    actual=$(config_get dns_alt_names)
    if test "${DNS_ALT_NAMES}" != "${actual}"; then
      echo "Warning: DNS_ALT_NAMES has been changed from the value in puppet.conf"
      echo "         Remove/revoke the old certificate for this to become effective"
    fi
  fi
fi
