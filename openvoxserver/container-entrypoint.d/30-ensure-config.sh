#!/bin/bash

set -e

puppet config set vardir /opt/puppetlabs/puppet/cache
puppet config set logdir /var/log/puppetlabs/puppet
puppet config set codedir /etc/puppetlabs/code
puppet config set rundir /var/run/puppetlabs
puppet config set manage_internal_file_permissions false