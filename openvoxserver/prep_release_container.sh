#!/bin/bash

set -e

apk update
apk add --no-cache dumb-init alpine-sdk openssh-client openssl libssh2 ruby ruby-dev runuser coreutils gcompat curl

gem install --no-document hiera-eyaml:${RUBYGEM_HIERA_EYAML}
gem install --no-document hocon:1.4.0
gem install --no-document openvox:${RUBYGEM_OPENVOX}
gem install --no-document openvoxserver-ca:${RUBYGEM_OPENVOXSERVER_CA}
gem install --no-document r10k:${RUBYGEM_R10K}
gem install --no-document racc:1.8.1
gem install --no-document syslog:0.4.0

apk del --purge alpine-sdk

# Create puppet user and group, and set permissions on necessary directories
# Used for rootless execution of the container and to match permissions expected by Puppet Server
addgroup -g ${OPENVOX_USER_GID} puppet
adduser -G puppet -u ${OPENVOX_USER_UID} -h /opt/puppetlabs/server/data/puppetserver -H -D -s /sbin/nologin puppet

chown -R puppet:puppet /etc/puppetlabs/code
chown -R puppet:puppet /etc/puppetlabs/puppet/ssl
chown -R puppet:puppet /etc/puppetlabs/puppetserver/ca
chown -R puppet:puppet /opt/puppetlabs/server/data/puppetserver
chown -R puppet:puppet /var/log/puppetlabs/puppetserver
chown -R puppet:puppet /var/run/puppetlabs/puppetserver

chmod 0700 /opt/puppetlabs/server/data/puppetserver/jars
chmod 0700 /opt/puppetlabs/server/data/puppetserver/yaml
chmod 0700 /var/log/puppetlabs/puppetserver
chmod 0750 /etc/puppetlabs/puppetserver
chmod 0770 /opt/puppetlabs/server/data/puppetserver

find /etc/puppetlabs/puppet/ssl -type d -exec chmod 0770 {} \;

mkdir -p /opt/puppetlabs/puppet/bin
ln -s /usr/bin/puppet /opt/puppetlabs/puppet/bin/puppet
ln -s /usr/bin/facter /opt/puppetlabs/puppet/bin/facter
ln -s /usr/bin/ruby /opt/puppetlabs/puppet/bin/ruby
ln -s /usr/bin/gem /opt/puppetlabs/puppet/bin/gem
ln -s /usr/bin/irb /opt/puppetlabs/puppet/bin/irb
ln -s /usr/bin/erb /opt/puppetlabs/puppet/bin/erb
ln -s /usr/bin/r10k /opt/puppetlabs/puppet/bin/r10k
ln -s /usr/bin/eyaml /opt/puppetlabs/puppet/bin/eyaml

# install puppet gem as library into jruby loadpath
puppetserver gem install --no-document openvox:${RUBYGEM_OPENVOX}

# use system/root paths instead of non-root paths to make permission management
# and volume mounting simpler. for this we link the appropiate paths and explicitly
# set the base paths used for interpolation, i.e confdir, codedir, vardir, rundir and
# logdir via the template and/or via `30-ensure-config.sh` in `puppet.conf`
#
mkdir -p ${HOME}/.puppetlabs/var
ln -sf /etc/puppetlabs ${HOME}/.puppetlabs/etc
ln -sf /opt/puppetlabs ${HOME}/.puppetlabs/opt
ln -sf /var/log/puppetlabs ${HOME}/.puppetlabs/var/log
ln -sf /var/run/puppetlabs ${HOME}/.puppetlabs/var/run

# mirror user permissions to group, set group to root, and set gid bit on dirs
for d in /etc/puppetlabs /var/log/puppetlabs /var/run/puppetlabs /opt/puppetlabs/
do
  mkdir -p "$d";
  chgrp -R 0 "$d";
  chmod -R g=u "$d";
  find "$d" -type d -exec chmod g+s {} +;
done

# the foreground starting script has this check before running the server:
# [ "$EUID" = "$(id -u ${USER})" ]
# simply calling `id -u` results in the UID of the current user and the check will pass
sed -i 's/^ *USER="puppet"/USER=""/' /etc/default/puppetserver

# TODO: check again in OpenVox 9
# remove the init_restart_file check from the foreground script since we don't use it and it causes permission issues when running as non-root
sed -i /init_restart_file/d /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground

rm /prep_release_container.sh
