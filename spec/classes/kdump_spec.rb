require 'spec_helper'

describe 'kdump' do
  include_context :defaults

  let(:facts) { default_facts }

  it { should create_class('kdump') }
  it { should contain_class('kdump::params') }

  it do
    should contain_kernel_parameter('crashkernel').with({
      'ensure'    => 'present',
      'value'     => '128M',
      'target'    => nil,
      'bootmode'  => 'all',
    })
  end

  it do
    should contain_package('kexec-tools').with({
      'ensure'    => 'present',
      'name'      => 'kexec-tools',
      'before'    => 'File[/etc/kdump.conf]',
    })
  end

  it do
    should contain_service('kdump').with({
      'ensure'      => 'stopped',
      'enable'      => 'false',
      'name'        => 'kdump',
      'hasstatus'   => 'true',
      'hasrestart'  => 'true',
      'subscribe'   => 'File[/etc/kdump.conf]',
    })
  end

  it do
    should contain_file('/etc/kdump.conf').with({
      'ensure'  => 'present',
      'path'    => '/etc/kdump.conf',
      'owner'   => 'root',
      'group'   => 'root',
      'mode'    => '0644',
    })
  end

  it 'should have default contents for /etc/kdump.conf' do
    verify_contents(subject, '/etc/kdump.conf', [
      'path /var/crash',
      'core_collector makedumpfile -c --message-level 1 -d 31',
    ])
  end

  context 'when memorysize_mb => 8192' do
    let(:facts) { default_facts.merge({ :memorysize_mb => '8192' }) }
    it { should contain_kernel_parameter('crashkernel').with_value('auto') }
  end

  context 'when operatingsystemrelease => 5.10' do
    let(:facts) { default_facts.merge({ :operatingsystemrelease => '5.10' }) }
    it { should contain_kernel_parameter('crashkernel').with_value('128M@16M') }
  end

  context 'with config_hashes defined as an Array of Hashes' do
    let(:params) do
      { 
        :config_hashes => [
          { 'path' => '/var/crash' },
          { 'core_collector' => 'makedumpfile -c --message-level 1 -d 31' },
          { 'kdump_post' => '/var/crash/scripts/kdump-post.sh' },
        ],
      }
    end

    it do
      verify_contents(subject, '/etc/kdump.conf', [
        'path /var/crash',
        'core_collector makedumpfile -c --message-level 1 -d 31',
        'kdump_post /var/crash/scripts/kdump-post.sh',
      ])
    end
  end

  context 'with config_hashes defined as an Array of Strings' do
    let(:params) do
      { 
        :config_hashes => [
          'path /var/crash',
          'core_collector makedumpfile -c --message-level 1 -d 31',
          'kdump_post /var/crash/scripts/kdump-post.sh',
        ],
      }
    end

    it do
      verify_contents(subject, '/etc/kdump.conf', [
        'path /var/crash',
        'core_collector makedumpfile -c --message-level 1 -d 31',
        'kdump_post /var/crash/scripts/kdump-post.sh',
      ])
    end
  end

  context 'with service_ensure => "undef"' do
    let(:params) {{ :service_ensure => "undef" }}
    it { should contain_service('kdump').with_ensure(nil) }
  end

  context 'with service_enable => "undef"' do
    let(:params) {{ :service_enable => "undef" }}
    it { should contain_service('kdump').with_enable(nil) }
  end

  context 'with service_autorestart => false' do
    let(:params) {{ :service_autorestart => false }}
    it { should contain_service('kdump').with_subscribe(nil) }
  end

  context 'with service_autorestart => "foo"' do
    let(:params) {{ :service_autorestart => "foo" }}
    it { expect { should create_class('kdump') }.to raise_error(Puppet::Error, /is not a boolean/) }
  end

  context 'with manage_config => false' do
    let(:params) {{ :manage_config => false }}
    it { should contain_package('kexec-tools').with_before(nil) }
    it { should contain_service('kdump').with_subscribe(nil) }
    it { should_not contain_file('/etc/kdump.conf') }
  end
end
