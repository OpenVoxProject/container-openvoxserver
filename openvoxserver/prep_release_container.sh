#!/bin/bash

set -e

if command -v apk >/dev/null 2>&1; then
  apk update
  apk add --no-cache \
    alpine-sdk \
    cmake \
    coreutils \
    curl \
    dumb-init \
    gcompat \
    git \
    jitterentropy-library-dev \
    libssh2 \
    libssh2-dev \
    zstd-dev \
    openssh-client \
    openssl \
    ruby-pkg-config \
    ruby \
    ruby-dev \
    runuser
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    coreutils \
    curl \
    dumb-init \
    git \
    libjitterentropy3-dev \
    libssh2-1-dev \
    libzstd-dev \
    netbase \
    openssh-client \
    openssl \
    pkg-config \
    ruby \
    ruby-dev \
    util-linux
else
  echo "Unsupported package manager" >&2
  exit 1
fi

# Install gems into the system CRuby gem path. These back the tools that run
# under the distro Ruby inside the container: the `puppet`/`facter` CLIs (used
# by the entrypoint, e.g. `puppet config print`), the `puppetserver ca` CLI
# (its cli/apps/ca app runs under the distro Ruby via /opt/puppetlabs/puppet/bin/ruby
# and needs openvoxserver-ca plus its hocon dependency), and the `r10k`
# convenience symlink created below. racc and syslog are stdlib gems dropped
# from default Ruby 3.4+, installed here for the distro Ruby. rugged is a native
# extension that cannot load on JRuby.
#
# NOTE: this path is NOT on puppetserver's JRuby gem-path. hiera-eyaml is needed
# only by the server JVM (for eyaml Hiera lookups), so it is installed solely
# into the JRuby gem-home further down, along with openvox. See #148.
gem install --no-document hocon:1.4.0
gem install --no-document openvox:${RUBYGEM_OPENVOX}
gem install --no-document openvoxserver-ca:${RUBYGEM_OPENVOXSERVER_CA}
gem install --no-document r10k:${RUBYGEM_R10K}
gem install --no-document rugged:${RUBYGEM_RUGGED} -- --with-ssh
gem install --no-document racc:1.8.1
gem install --no-document syslog:0.4.0

if command -v apk >/dev/null 2>&1; then
  apk del --purge alpine-sdk
else
  apt-get purge -y build-essential
  apt-get autoremove -y
  apt-get clean
  rm -rf /var/lib/apt/lists/*
fi

# Create puppet user and group, and set permissions on necessary directories
# Used for rootless execution of the container and to match permissions expected by Puppet Server
if command -v addgroup >/dev/null 2>&1 && command -v apk >/dev/null 2>&1; then
  addgroup -g "${OPENVOX_USER_GID}" puppet
  adduser -G puppet -u "${OPENVOX_USER_UID}" -h /opt/puppetlabs/server/data/puppetserver -H -D -s /sbin/nologin puppet
else
  groupadd --gid "${OPENVOX_USER_GID}" puppet
  useradd \
    --gid puppet \
    --home-dir /opt/puppetlabs/server/data/puppetserver \
    --no-create-home \
    --shell /usr/sbin/nologin \
    --uid "${OPENVOX_USER_UID}" \
    puppet
fi

chown -R puppet:puppet /etc/puppetlabs/code
chown -R puppet:puppet /etc/puppetlabs/puppet
chown -R puppet:puppet /etc/puppetlabs/puppetserver
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
for executable in puppet facter ruby gem irb erb r10k; do
  ln -s "$(command -v "$executable")" "/opt/puppetlabs/puppet/bin/$executable"
done

for executable in puppet facter r10k; do
  ln -s "../puppet/bin/$executable" "/opt/puppetlabs/bin/$executable"
done

# Install the gems the puppetserver JVM loads at runtime into the JRuby
# gem-home. The `gem install` calls above only populate the distro CRuby gem
# path (e.g. /var/lib/gems/3.x), which is NOT on puppetserver's JRuby gem-path,
# so any gem the server loads is invisible there. openvox provides puppet as a
# server library, and hiera-eyaml is required for eyaml-encrypted Hiera lookups
# during catalog compilation. The other gems above are CLI tools that run under
# the distro Ruby (not the JVM), so they are not needed here. See #148.
puppetserver gem install --no-document openvox:${RUBYGEM_OPENVOX}
puppetserver gem install --no-document hiera-eyaml:${RUBYGEM_HIERA_EYAML}

# Colocate the puppetdb termini with the openvox gem lib so the puppetdb_query
# function resolves during compilation. The termini in vendor_ruby (on
# ruby-load-path) cover the require-loaded terminus and report processor, but
# Puppet 4 functions load via the Pops system loader, rooted at puppet's own lib
# rather than ruby-load-path. Since #141 gem-installs openvox instead of using
# the OS packages (whose openvoxdb-termini colocated everything in vendor_ruby),
# that root is the gem lib, so puppetdb_query would otherwise be unknown.
cp -r /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet \
  "/opt/puppetlabs/server/data/puppetserver/jruby-gems/gems/openvox-${RUBYGEM_OPENVOX}/lib/"

# Expose the `eyaml` CLI. hiera-eyaml lives only in the JRuby gem-home, and its
# binstub there resolves the gem against the default (distro) gem-path, where it
# is no longer installed, so it can't simply be symlinked. Wrap it to run under
# the distro Ruby with GEM_PATH pointed at the JRuby gem-home; hiera-eyaml is a
# pure-Ruby gem, so it loads fine there and we avoid JVM start-up. The CLI is
# essentially never used inside the container, it is provided only for the
# occasional manual eyaml encrypt/decrypt.
cat >/opt/puppetlabs/puppet/bin/eyaml <<'SCRIPT'
#!/bin/bash
export GEM_PATH="/opt/puppetlabs/server/data/puppetserver/jruby-gems${GEM_PATH:+:$GEM_PATH}"
exec ruby /opt/puppetlabs/server/data/puppetserver/jruby-gems/bin/eyaml "$@"
SCRIPT
chmod 0755 /opt/puppetlabs/puppet/bin/eyaml

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
for d in /etc/puppetlabs /var/log/puppetlabs /var/run/puppetlabs /opt/puppetlabs/ /run/openvox; do
  mkdir -p "$d"
  chgrp -R 0 "$d"
  chmod -R g=u "$d"
  find "$d" -type d -exec chmod g+s {} +
done

# the foreground starting script has this check before running the server:
# [ "$EUID" = "$(id -u ${USER})" ]
# simply calling `id -u` results in the UID of the current user and the check will pass
sed -i 's/^ *USER="puppet"/USER=""/' /etc/default/puppetserver

# TODO: check again in OpenVox 9
# remove the init_restart_file check from the foreground script since we don't use it and it causes permission issues when running as non-root
sed -i /init_restart_file/d /opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground

rm /prep_release_container.sh
