#!/bin/bash

set -e

CA_DIR="/etc/puppetlabs/puppetserver/ca"

# Check if CA directory is present and owned by any a different user
if [ -d "$CA_DIR" ] && [ "$(stat -c '%u' "$CA_DIR")" != "$OPENVOX_USER_UID" ]; then
  echo "Adjusting mounted CA directory ownership. This may take time. Please wait."
  chown -R "$OPENVOX_USER_UID:$OPENVOX_USER_GID" "$CA_DIR" || echo "Failed to chown $CA_DIR"
fi
