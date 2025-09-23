#!/bin/bash

set -e

# determine script location
readonly SCRIPT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
readonly SCRIPT_PATH=$(dirname "$SCRIPT_FILENAME")

if [[ "$OPENVOXSERVER_GRAPHITE_EXPORTER_ENABLED" == "true" ]]; then
  # Only check for CERTNAME if graphite exporter is enabled
  if [[ -z "$CERTNAME" ]]; then
    echo "ERROR: CERTNAME environment variable is not set, and is required for the graphite exporter configuration."
    exit 1
  fi
  
  if [[ -n "$OPENVOXSERVER_GRAPHITE_HOST" && -n "$OPENVOXSERVER_GRAPHITE_PORT" ]]; then
    echo "Enabling graphite exporter"
    # Use multiple -e flags to perform multiple substitutions in a single pass
    sed -e "s/GRAPHITE_HOST/$OPENVOXSERVER_GRAPHITE_HOST/" \
        -e "s/GRAPHITE_PORT/$OPENVOXSERVER_GRAPHITE_PORT/" \
        -e "s/server-id: localhost/server-id: $CERTNAME/" \
        "$SCRIPT_PATH/84-metrics.conf.tmpl" > /etc/puppetlabs/puppetserver/conf.d/metrics.conf
  else
    echo "ERROR: no OPENVOXSERVER_GRAPHITE_HOST or OPENVOXSERVER_GRAPHITE_PORT set."
    exit 99
  fi
fi
