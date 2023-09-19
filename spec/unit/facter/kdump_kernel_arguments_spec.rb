# frozen_string_literal: true

require 'spec_helper'

describe 'kdump_kernel_arguments fact' do
  before :each do
    Facter.clear
  end

  context 'when kernel is linux' do
    it 'returns output from /proc/cmdline' do
      expected_value = my_fixture_read('cmdline1')
      allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
      allow(Facter::Core::Execution).to receive(:execute).with('cat /proc/cmdline 2>/dev/null').and_return(expected_value)
      expect(Facter.fact(:kdump_kernel_arguments).value).to eq(expected_value)
    end
  end
end
