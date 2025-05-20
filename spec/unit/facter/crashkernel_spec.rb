# frozen_string_literal: true

require 'spec_helper'

describe 'crashkernel fact' do
  before :each do
    Facter.clear
  end

  context 'when kernel is linux' do
    before(:each) do
      allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
    end

    it 'returns crashkernel' do
      allow(Facter).to receive(:value).with(:kdump_kernel_arguments).and_return(my_fixture_read('kernelargs-with-crash.txt'))
      expect(Facter.fact(:crashkernel).value).to eq('131M@0M')
    end

    it 'returns false' do
      allow(Facter).to receive(:value).with(:kdump_kernel_arguments).and_return(my_fixture_read('kernelargs-without-crash.txt'))
      expect(Facter.fact(:crashkernel).value).to eq(false)
    end

    it 'returns false when no' do
      allow(Facter).to receive(:value).with(:kdump_kernel_arguments).and_return(my_fixture_read('kernelargs-with-crash-no.txt'))
      expect(Facter.fact(:crashkernel).value).to eq(false)
    end
  end
end
