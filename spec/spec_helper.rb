require 'puppetlabs_spec_helper/module_spec_helper'

shared_context :defaults do
  let :default_facts do
    {
      :kernel                 => 'Linux',
      :osfamily               => 'RedHat',
      :operatingsystem        => 'CentOS',
      :operatingsystemrelease => '6.4',
      :architecture           => 'x86_64',
      :memorysize_mb          => '512',
    }
  end
end
