#!/bin/bash

set -e

if [[ "$OPENVOXSERVER_GRAPHITE_EXPORTER_ENABLED" == "true" ]]; then
  if [[ -n "$OPENVOXSERVER_GRAPHITE_HOST" && -n "$OPENVOXSERVER_GRAPHITE_PORT" ]]; then
    echo "Enabling graphite exporter"
    sed -e "s/GRAPHITE_HOST/$OPENVOXSERVER_GRAPHITE_HOST/" -e "s/GRAPHITE_PORT/$OPENVOXSERVER_GRAPHITE_PORT/" /docker-entrypoint.d/84-metrics.conf.tmpl > /etc/puppetlabs/puppetserver/conf.d/metrics.conf
  else
    echo "ERROR: no OPENVOXSERVER_GRAPHITE_HOST or OPENVOXSERVER_GRAPHITE_PORT set."
    exit 99
  fi
fi
