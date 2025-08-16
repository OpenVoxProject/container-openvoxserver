#!/bin/bash

set -e

# determine script location
readonly SCRIPT_FILENAME=$(readlink -f "${BASH_SOURCE[0]}")
readonly SCRIPT_PATH=$(dirname "$SCRIPT_FILENAME")

if [ -n "${CSR_ATTRIBUTES}" ]; then
    echo "CSR Attributes: ${CSR_ATTRIBUTES}"
    /opt/puppetlabs/puppet/bin/ruby "$SCRIPT_PATH/89-csr_attributes.rb"
fi
