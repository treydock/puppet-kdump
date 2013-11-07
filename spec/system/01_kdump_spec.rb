require 'spec_helper_system'

describe 'kdump class:' do
  context 'should run successfully' do
    pp =<<-EOS
class { 'kdump': }
    EOS
  
    context puppet_apply(pp) do
       its(:stderr) { should be_empty }
       its(:exit_code) { should_not == 1 }
       its(:refresh) { should be_nil }
       its(:stderr) { should be_empty }
       its(:exit_code) { should be_zero }
    end
  end

  describe package('kexec-tools') do
    it { should be_installed }
  end

  describe service('kdump') do
    it { should_not be_enabled }
    it { should_not be_running }
  end

  describe file('/etc/kdump.conf') do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    its(:content) { should match /^path \/var\/crash\ncore_collector makedumpfile -c --message-level 1 -d 31/ }
  end

  describe file('/boot/grub/menu.lst') do
    it { should contain 'crashkernel=128M' }
  end
end
