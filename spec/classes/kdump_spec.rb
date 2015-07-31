require 'spec_helper'

describe 'kdump' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      case facts[:operatingsystemmajrelease]
      when '7'
        kernel_parameter_provider = 'grub2'
      else
        kernel_parameter_provider = 'grub'
      end

      it { should create_class('kdump') }
      it { should contain_class('kdump::params') }

      it 'should remove crashkernel parameter' do
        should contain_kernel_parameter('crashkernel').with({
          :ensure   => 'absent',
          :provider => kernel_parameter_provider,
        })
      end

      it do
        should contain_service('kdump').with({
          :ensure       => 'stopped',
          :enable       => 'false',
          :name         => 'kdump',
          :hasstatus    => 'true',
          :hasrestart   => 'true',
        })
      end

      it { should_not contain_package('kexec-tools') }
      it { should_not contain_file('/etc/kdump.conf') }

      context 'when enable => true' do
        let(:params) {{ :enable => true }}
    
        it do
          should contain_kernel_parameter('crashkernel').with({
            :ensure     => 'present',
            :value      => 'auto',
            :target     => nil,
            :bootmode   => 'all',
            :provider   => kernel_parameter_provider,
          })
        end

        it do
          should contain_package('kexec-tools').with({
            :ensure     => 'present',
            :name       => 'kexec-tools',
            :before     => 'File[/etc/kdump.conf]',
          })
        end

        it do
          should contain_file('/etc/kdump.conf').with({
            :ensure   => 'present',
            :path     => '/etc/kdump.conf',
            :owner    => 'root',
            :group    => 'root',
            :mode     => '0644',
            :notify   => 'Service[kdump]',
          })
        end

        it 'should have default contents for /etc/kdump.conf' do
          verify_contents(catalogue, '/etc/kdump.conf', [
            'core_collector makedumpfile -c --message-level 1 -d 31',
            'path /var/crash',
          ])
        end

        it do
          should contain_service('kdump').with({
            :ensure       => 'running',
            :enable       => 'true',
            :name         => 'kdump',
            :hasstatus    => 'true',
            :hasrestart   => 'true',
          })
        end

        context 'with config_hashes defined' do
          let(:params) do
            { 
              :enable => true,
              :config_overrides => {
                'path' => '/var/crash',
                'core_collector' => 'makedumpfile -c --message-level 1 -d 31',
                'kdump_post' => '/var/crash/scripts/kdump-post.sh',
              },
            }
          end

          it do
            verify_contents(catalogue, '/etc/kdump.conf', [
              'core_collector makedumpfile -c --message-level 1 -d 31',
              'kdump_post /var/crash/scripts/kdump-post.sh',
              'path /var/crash',
            ])
          end
        end
      end
    end
  end
end
