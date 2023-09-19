# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'kdump class:' do
  let(:pp) do
    <<-PP
     # Set crashkernel variable because auto
     # does not work in RAM < 1G which could
     # happen in the hypervisor
      class { 'kdump':
        enable => true,
        crashkernel => '128M'
       }
    PP
  end

  let(:pp_disable) do
    <<-PP
      class { 'kdump': enable => false }
    PP
  end

  hosts.each do |host|
    context 'when enable => true' do
      it 'runs successfully' do
        # It will fail because kdump service can not start until after reboot.
        apply_manifest_on(host, pp, catch_failures: false)
        host.reboot
        sleep 60
      end

      it 'is idempotent' do
        apply_manifest_on(host, pp, catch_changes: true)
      end

      it 'has kernel param and kexex package installed' do
        result = on(host, %(cat /proc/cmdline)).stdout
        expect(result).to match(%r{crashkernel})
        expect(check_for_package(host, 'kexec-tools')).to be true
      end

      it 'has /etc/kdump.conf configured' do
        result = on(host, %(cat /etc/kdump.conf)).stdout
        expect(result).to match(%r{^core_collector makedumpfile -c --message-level 1 -d 31\npath /var/crash})
      end
      #
      #      it 'is expected to create a file in /var/crash ' do
      #        on host, '/bin/echo "1" > /proc/sys/kernel/sysrq'
      #        on host,  '/bin/echo "c" > /proc/sysrq-trigger', { :silent => true, :reset_connection => true}
      #        filelist = on(host, %(find /var/crash -name vmcore)).stdout
      #        expect(result).to match(/vmcore/)
      #      end
    end

    context 'when disable kdump' do
      it 'runs successfully' do
        apply_manifest_on(host, pp_disable, catch_failures: true)
        host.reboot
        sleep 60
      end

      it 'is idempotent' do
        apply_manifest_on(host, pp_disable, catch_changes: true)
      end

      it 'does not have kernel param crashkernel' do
        result = on(host, %(cat /proc/cmdline)).stdout
        expect(result).not_to match(%r{crashkernel})
      end

      describe service('kdump') do
        it { is_expected.not_to be_enabled }
        it { is_expected.not_to be_running }
      end
    end
  end
end
