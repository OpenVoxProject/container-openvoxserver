#!/bin/bash

set -e

# init confdir for non-root user
[ ! -d ~/.puppetlabs/etc/puppet ] && mkdir -p ~/.puppetlabs/etc/puppet
# to make CLI tools work properly confdir and codedir need the same as the user dirs (defaults to root user dirs)
hocon -f /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf set jruby-puppet.master-conf-dir $(puppet config print confdir)
hocon -f /etc/puppetlabs/puppetserver/conf.d/puppetserver.conf set jruby-puppet.master-code-dir $(puppet config print codedir)  
