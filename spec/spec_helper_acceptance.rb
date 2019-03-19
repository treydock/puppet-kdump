require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

#hosts.each do |host|
#  # Install Puppet
#  # Install Puppet
#  if host['platform'] =~ /el-(5|6)/
#    relver = $1
#    on host, "rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-#{relver}.noarch.rpm", { :acceptable_exit_codes => [0,1] }
#    on host, 'yum install -y puppet puppet-server', { :acceptable_exit_codes => [0,1] }
#    on host, 'service puppetmaster start', { :acceptable_exit_codes => [0,1] }
#  end
#end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'kdump')

    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'herculesteam-augeasproviders_grub'), { :acceptable_exit_codes => [0,1] }
    end
  end
end
