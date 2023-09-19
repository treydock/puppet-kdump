# frozen_string_literal: true

# Fact: kdump_kernel_arguments
#
# Purpose:
#   This fact provides the arguments used for the currently running kernel
#
# Resolution:
#   Checks `proc/cmdline`
#
# Caveats:
#   Only supports Linux.
#

Facter.add(:kdump_kernel_arguments) do
  confine kernel: :linux
  setcode do
    cmdline_out = Facter::Core::Execution.execute('cat /proc/cmdline 2>/dev/null')
    cmdline_out
  end
end
