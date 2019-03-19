require 'spec_helper_acceptance'

describe 'kdump class:' do
  let(:pp) {
     <<-EOS
     # Set crashkernel variable because auto
     # does not work in RAM < 1G which could
     # happen in the hypervisor
      class { 'kdump':
        enable => true,
        crashkernel => '128M'
       }
    EOS
  }

  let(:pp_disable) {
     <<-EOS
      class { 'kdump': enable => false }
    EOS
  }

  hosts.each do |host|
    context 'enable => true' do
      it 'should run successfully' do
        # It will fail because kdump service can not start until after reboot.
        apply_manifest_on(host, pp, :catch_failures => false)
      end

      it 'should reboot and be idempotent' do
          host.reboot
          apply_manifest_on(host, pp, :catch_changes => false)
          apply_manifest_on(host, pp, :catch_changes => true)
      end

      it 'should have kernel param and kexex package installed' do
        result = on(host, %(cat /proc/cmdline)).stdout
        expect(result).to match(/crashkernel/)
        expect(check_for_package(host, 'kexec-tools')).to be true
      end


      it 'should have /etc/kdump.conf configured' do
        result = on(host, %(cat /etc/kdump.conf)).stdout
        expect(result).to match(/^core_collector makedumpfile -c --message-level 1 -d 31\npath \/var\/crash/)
      end
#
#      it 'is expected to create a file in /var/crash ' do
#        on host, '/bin/echo "1" > /proc/sys/kernel/sysrq'
#        on host,  '/bin/echo "c" > /proc/sysrq-trigger', { :silent => true, :reset_connection => true}
#        filelist = on(host, %(find /var/crash -name vmcore)).stdout
#        expect(result).to match(/vmcore/)
#      end

    end

    context 'disable kdump' do
      it 'should run successfully' do
        apply_manifest_on(host, pp_disable, :catch_failures => true)
        host.reboot
        apply_manifest_on(host, pp_disable, :catch_changes => true)
      end

      it 'should not have kernel param crashkernel' do
        result = on(host, %(cat /proc/cmdline)).stdout
        expect(result).to_not match(/crashkernel/)
      end

      describe service('kdump') do
        it { should_not be_enabled }
        it { should_not be_running }
      end

    end
  end
end
