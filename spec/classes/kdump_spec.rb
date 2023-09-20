# frozen_string_literal: true

require 'spec_helper'

describe 'kdump' do
  on_supported_os.each do |os, facts|
    context "when #{os}" do
      let(:facts) do
        facts.merge(crashkernel: 'auto')
      end

      let(:crashkernel) do
        if facts[:os]['family'] == 'RedHat' && facts[:os]['release']['major'].to_s == '9'
          '1G-4G:192M,4G-64G:256M,64G:512M'
        else
          'auto'
        end
      end

      let(:package_name) do
        case facts[:os]['family']
        when 'Debian'
          'kdump-tools'
        when 'RedHat'
          'kexec-tools'
        end
      end

      let(:service_name) do
        case facts[:os]['family']
        when 'Debian'
          'kdump-tools'
        when 'RedHat'
          'kdump'
        end
      end

      it { is_expected.to create_class('kdump') }

      it 'removes crashkernel parameter' do
        is_expected.to contain_kernel_parameter('crashkernel').with(ensure: 'absent',
                                                                    provider: 'grub2')
      end

      it do
        is_expected.to contain_service('kdump').with(ensure: 'stopped',
                                                     enable: 'false',
                                                     name: service_name,
                                                     hasstatus: 'true',
                                                     hasrestart: 'true')
      end

      it { is_expected.not_to contain_package('kexec-tools') }
      it { is_expected.not_to contain_file('/etc/kdump.conf') }

      it do
        is_expected.to contain_notify('kdump').with_message('A reboot is required to fully disable the crashkernel')
      end

      context 'when kernel_arguments does not contain crashkernel' do
        let(:facts) do
          facts.merge(crashkernel: false)
        end

        it do
          is_expected.not_to contain_notify('kdump')
        end
      end

      context 'when enable => true' do
        let(:params) { { enable: true } }

        it do
          is_expected.to contain_kernel_parameter('crashkernel').with(ensure: 'present',
                                                                      value: crashkernel,
                                                                      target: nil,
                                                                      bootmode: 'all',
                                                                      provider: 'grub2')
        end

        it do
          is_expected.to contain_package('kexec-tools').with(ensure: 'installed',
                                                             name: package_name,
                                                             before: 'File[/etc/kdump.conf]')
        end

        it do
          is_expected.to contain_file('/etc/kdump.conf').with(ensure: 'file',
                                                              path: '/etc/kdump.conf',
                                                              owner: 'root',
                                                              group: 'root',
                                                              mode: '0644',
                                                              notify: 'Service[kdump]')
        end

        it 'has default contents for /etc/kdump.conf' do
          verify_contents(catalogue, '/etc/kdump.conf', [
                            'core_collector makedumpfile -c --message-level 1 -d 31',
                            'path /var/crash'
                          ])
        end

        it do
          is_expected.not_to contain_notify('kdump')
        end

        context 'when kernel_arguments does not contain crashkernel' do
          let(:facts) do
            facts.merge(crashkernel: false)
          end

          it { is_expected.to contain_service('kdump').with_ensure('stopped') }

          it do
            is_expected.to contain_notify('kdump').with_message('A reboot is required to fully enable the crashkernel')
          end
        end

        it do
          is_expected.to contain_service('kdump').with(ensure: 'running',
                                                       enable: 'true',
                                                       name: service_name,
                                                       hasstatus: 'true',
                                                       hasrestart: 'true')
        end

        context 'with config_hashes defined' do
          let(:params) do
            {
              enable: true,
              config_overrides: {
                'path' => '/var/crash',
                'core_collector' => 'makedumpfile -c --message-level 1 -d 31',
                'kdump_post' => '/var/crash/scripts/kdump-post.sh'
              }
            }
          end

          it do
            verify_contents(catalogue, '/etc/kdump.conf', [
                              'core_collector makedumpfile -c --message-level 1 -d 31',
                              'kdump_post /var/crash/scripts/kdump-post.sh',
                              'path /var/crash'
                            ])
          end
        end
      end
    end
  end
end
