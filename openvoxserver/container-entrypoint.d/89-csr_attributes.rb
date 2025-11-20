#!/opt/puppetlabs/puppet/bin/ruby

require 'json'
require 'yaml'

target_path = ARGV[0] || '/etc/puppetlabs/puppet/csr_attributes.yaml'
begin
  csr_yaml = YAML.dump(JSON.load(ENV['CSR_ATTRIBUTES']))
  File.write(target_path, csr_yaml)
rescue => error
  puts "Error on reading JSON env. Terminating"
  puts "Malformed JSON: #{ENV['CSR_ATTRIBUTES']}"
  p error.message
  exit 99
end
