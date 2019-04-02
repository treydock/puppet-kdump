require 'spec_helper'

describe 'kernel_arguments fact' do
  before :each do
    Facter.clear
  end

  context 'kernel is linux' do
    it 'should return output from /proc/cmdline' do
      expected_value = my_fixture_read('cmdline1')
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
      allow(Facter::Core::Execution).to receive(:execute).with('cat /proc/cmdline 2>/dev/null').and_return(expected_value)
      expect(Facter.fact(:kernel_arguments).value).to eq(expected_value)
    end
  end
end
