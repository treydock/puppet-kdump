require 'spec_helper_acceptance'

describe 'kdump class:' do
  context 'enable => true' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'kdump': enable => true }
      EOS

      pending("fails due to crashkernel not being in GRUB boot") do
        apply_manifest(pp, :catch_failures => true)
      end
      pending("fails due to crashkernel not being in GRUB boot") do
        apply_manifest(pp, :catch_changes => true)
      end
    end

    describe package('kexec-tools') do
      it { should be_installed }
    end

    describe file('/boot/grub/menu.lst') do
      its(:content) { should match /crashkernel=auto/ }
    end

    describe file('/etc/kdump.conf') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      its(:content) { should match /^core_collector makedumpfile -c --message-level 1 -d 31\npath \/var\/crash/ }
    end

    describe service('kdump') do
      it { should be_enabled }
      pending("fails due to crashkernel not being in GRUB boot") do
        it { should be_running }
      end
    end
  end

  context 'default parameters' do
    it 'should run successfully' do
      pp =<<-EOS
      class { 'kdump': }
      EOS

      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    describe service('kdump') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe file('/boot/grub/menu.lst') do
      its(:content) { should_not match /crashkernel/ }
    end
  end
end
