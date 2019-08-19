require 'spec_helper'

describe 'crashkernel fact' do
  before :each do
    Facter.clear
  end

  context 'kernel is linux' do
    it 'returns crashkernel' do
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
      allow(Facter).to receive(:value).with(:kdump_kernel_arguments).and_return(my_fixture_read('kernelargs-with-crash.txt'))
      expect(Facter.fact(:crashkernel).value).to eq('131M@0M')
    end
    it 'returns false' do
      allow(Facter::Core::Execution).to receive(:exec).with('uname -s').and_return('Linux')
      allow(Facter).to receive(:value).with(:kdump_kernel_arguments).and_return(my_fixture_read('kernelargs-without-crash.txt'))
      expect(Facter.fact(:crashkernel).value).to eq(false)
    end
  end
end
