#!/bin/bash

set -e

source /usr/local/share/openvox/config_lib.sh

config_set server hiera_config $HIERACONFIG
