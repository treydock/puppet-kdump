require 'spec_helper'

describe 'kdump' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(kernel_arguments: my_fixture_read('kernelargs-with-crash.txt'))
      end

      kernel_parameter_provider = case facts[:operatingsystemmajrelease]
                                  when '7'
                                    'grub2'
                                  else
                                    'grub'
                                  end

      it { is_expected.to create_class('kdump') }

      it 'removes crashkernel parameter' do
        is_expected.to contain_kernel_parameter('crashkernel').with(ensure: 'absent',
                                                                    provider: kernel_parameter_provider)
      end

      it do
        is_expected.to contain_service('kdump').with(ensure: 'stopped',
                                                     enable: 'false',
                                                     name: 'kdump',
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
          facts.merge(kernel_arguments: my_fixture_read('kernelargs-without-crash.txt'))
        end

        it do
          is_expected.not_to contain_notify('kdump')
        end
      end

      context 'when enable => true' do
        let(:params) { { enable: true } }

        it do
          is_expected.to contain_kernel_parameter('crashkernel').with(ensure: 'present',
                                                                      value: 'auto',
                                                                      target: nil,
                                                                      bootmode: 'all',
                                                                      provider: kernel_parameter_provider)
        end

        it do
          is_expected.to contain_package('kexec-tools').with(ensure: 'present',
                                                             name: 'kexec-tools',
                                                             before: 'File[/etc/kdump.conf]')
        end

        it do
          is_expected.to contain_file('/etc/kdump.conf').with(ensure: 'present',
                                                              path: '/etc/kdump.conf',
                                                              owner: 'root',
                                                              group: 'root',
                                                              mode: '0644',
                                                              notify: 'Service[kdump]')
        end

        it 'has default contents for /etc/kdump.conf' do
          verify_contents(catalogue, '/etc/kdump.conf', [
                            'core_collector makedumpfile -c --message-level 1 -d 31',
                            'path /var/crash',
                          ])
        end

        it do
          is_expected.not_to contain_notify('kdump')
        end

        context 'when kernel_arguments does not contain crashkernel' do
          let(:facts) do
            facts.merge(kernel_arguments: my_fixture_read('kernelargs-without-crash.txt'))
          end

          it do
            is_expected.to contain_notify('kdump').with_message('A reboot is required to fully enable the crashkernel')
          end
        end

        it do
          is_expected.to contain_service('kdump').with(ensure: 'running',
                                                       enable: 'true',
                                                       name: 'kdump',
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
