require 'spec_helper'

describe 'kdump' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({
          :kernel_arguments => 'ro root=/dev/mapper/vg_sys-lv_root rd_LVM_LV=vg_sys/lv_swap rd_NO_LUKS LANG=en_US.UTF-8 rd_NO_MD  KEYTABLE=us nofb quiet splash=quiet SYSFONT=latarcyrheb-sun16 rd_LVM_LV=vg_sys/lv_root rd_NO_DM rhgb quiet crashkernel=131M@0M'
        })
      end

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

      it do
        should contain_notify('kdump').with_message('A reboot is required to fully disable the crashkernel')
      end

      context 'when kernel_arguments does not contain crashkernel' do
        let(:facts) do
          facts.merge({
            :kernel_arguments => 'ro root=/dev/mapper/vg_sys-lv_root rd_LVM_LV=vg_sys/lv_swap rd_NO_LUKS LANG=en_US.UTF-8 rd_NO_MD  KEYTABLE=us nofb quiet splash=quiet SYSFONT=latarcyrheb-sun16 rd_LVM_LV=vg_sys/lv_root rd_NO_DM rhgb quiet'
          })
        end

        it do
          should_not contain_notify('kdump')
        end
      end

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
          should_not contain_notify('kdump')
        end

        context 'when kernel_arguments does not contain crashkernel' do
          let(:facts) do
            facts.merge({
              :kernel_arguments => 'ro root=/dev/mapper/vg_sys-lv_root rd_LVM_LV=vg_sys/lv_swap rd_NO_LUKS LANG=en_US.UTF-8 rd_NO_MD  KEYTABLE=us nofb quiet splash=quiet SYSFONT=latarcyrheb-sun16 rd_LVM_LV=vg_sys/lv_root rd_NO_DM rhgb quiet'
            })
          end

          it do
            should contain_notify('kdump').with_message('A reboot is required to fully enable the crashkernel')
          end
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
