#!/opt/puppetlabs/puppet/bin/ruby

# Helper script using Puppet's own INI manipulator in place of `pupppet config`.
# See /usr/local/share/openvox/config_lib.sh for the companion script.

require 'puppet'
require 'puppet/settings/ini_file'

command = ARGV.shift
section = ARGV.shift

# This bit is largely referencing openvox's lib/puppet/face/config.rb
File.open('/etc/puppetlabs/puppet/puppet.conf', 'r+') do |file|
  Puppet::Settings::IniFile.update(file) do |config|
    if command == 'set'
      ARGV.each_slice(2) do |key, value|
        config.set(section, key, value)
      end
    else
      ARGV.each do |key|
        config.delete(section, key)
      end
    end
  end
end
