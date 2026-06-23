#!/bin/bash

set -e

tar -x -z -f /openvox-server-${OPENVOXSERVER_VERSION}.tar.gz -C /
tar -x -z -f /openvoxdb-${OPENVOXDB_VERSION}.tar.gz -C /

cd /puppetserver-${OPENVOXSERVER_VERSION}

install -d "/etc/puppetlabs/code" -m 0755
install -d "/etc/puppetlabs/puppet/ssl" -m 0770
install -d "/etc/puppetlabs/puppetserver/ca" -m 0750
install -d "/etc/puppetlabs/puppetserver/conf.d" -m 0755
install -d "/etc/puppetlabs/puppetserver/services.d" -m 0755
install -d "/opt/puppetlabs/bin" -m 0755
install -d "/opt/puppetlabs/server/apps/puppetserver" -m 0755
install -d "/opt/puppetlabs/server/apps/puppetserver/bin" -m 0755
install -d "/opt/puppetlabs/server/apps/puppetserver/cli" -m 0755
install -d "/opt/puppetlabs/server/apps/puppetserver/cli/apps" -m 0755
install -d "/opt/puppetlabs/server/apps/puppetserver/config/services.d" -m 0755
install -d "/opt/puppetlabs/server/bin" -m 0755
install -d "/opt/puppetlabs/server/data" -m 0775
install -d "/opt/puppetlabs/server/data/puppetserver" -m 0770
install -d "/opt/puppetlabs/server/data/puppetserver/jars" -m 0700
install -d "/opt/puppetlabs/server/data/puppetserver/jruby-gems" -m 0755
install -d "/opt/puppetlabs/server/data/puppetserver/var" -m 0770
install -d "/opt/puppetlabs/server/data/puppetserver/yaml" -m 0700
install -d "/var/log/puppetlabs/puppetserver" -m 0700
install -d "/var/run/puppetlabs/puppetserver" -m 0755

install ext/bin/puppetserver                       "/opt/puppetlabs/server/apps/puppetserver/bin/puppetserver" -m 0755
install ext/cli_defaults/cli-defaults.sh           "/opt/puppetlabs/server/apps/puppetserver/cli" -m 0755
install ext/cli/ca                                 "/opt/puppetlabs/server/apps/puppetserver/cli/apps/ca" -m 0755
install ext/cli/foreground                         "/opt/puppetlabs/server/apps/puppetserver/cli/apps/foreground" -m 0755
install ext/cli/gem                                "/opt/puppetlabs/server/apps/puppetserver/cli/apps/gem" -m 0755
install ext/cli/irb                                "/opt/puppetlabs/server/apps/puppetserver/cli/apps/irb" -m 0755
install ext/cli/prune                              "/opt/puppetlabs/server/apps/puppetserver/cli/apps/prune" -m 0755
install ext/cli/ruby                               "/opt/puppetlabs/server/apps/puppetserver/cli/apps/ruby" -m 0755

install ext/config/conf.d/auth.conf                "/etc/puppetlabs/puppetserver/conf.d/auth.conf" -m 0644
install ext/config/conf.d/ca.conf                  "/etc/puppetlabs/puppetserver/conf.d/ca.conf" -m 0644
install ext/config/conf.d/global.conf              "/etc/puppetlabs/puppetserver/conf.d/global.conf" -m 0644
install ext/config/conf.d/metrics.conf             "/etc/puppetlabs/puppetserver/conf.d/metrics.conf" -m 0644
install ext/config/conf.d/puppetserver.conf        "/etc/puppetlabs/puppetserver/conf.d/puppetserver.conf" -m 0644
install ext/config/conf.d/web-routes.conf          "/etc/puppetlabs/puppetserver/conf.d/web-routes.conf" -m 0644
install ext/config/conf.d/webserver.conf           "/etc/puppetlabs/puppetserver/conf.d/webserver.conf" -m 0644

install ext/config/logback.xml                     "/etc/puppetlabs/puppetserver/logback.xml" -m 0644
install ext/config/request-logging.xml             "/etc/puppetlabs/puppetserver/request-logging.xml" -m 0644
install ext/config/services.d/ca.cfg               "/etc/puppetlabs/puppetserver/services.d/ca.cfg" -m 0644

install ext/system-config/services.d/bootstrap.cfg "/opt/puppetlabs/server/apps/puppetserver/config/services.d/bootstrap.cfg" -m 0644
install puppet-server-release.jar                  "/opt/puppetlabs/server/apps/puppetserver" -m 0644
install ext/ezbake-functions.sh                    "/opt/puppetlabs/server/apps/puppetserver/ezbake-functions.sh" -m 0755

ln -s "../apps/puppetserver/bin/puppetserver" "/opt/puppetlabs/server/bin/puppetserver"
ln -s "../server/apps/puppetserver/bin/puppetserver" "/opt/puppetlabs/bin/puppetserver"

bash ext/build-scripts/install-vendored-gems.sh

# puppetdb-termini
cd /puppetdb-${OPENVOXDB_VERSION}
RUBY_LIB_DIR="/opt/puppetlabs/puppet/lib/ruby/vendor_ruby"
install -d "$RUBY_LIB_DIR"
cp -r puppet "$RUBY_LIB_DIR/"
