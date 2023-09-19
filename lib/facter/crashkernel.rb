# frozen_string_literal: true

# Fact: crashkernel
#
# Purpose:
#   This fact checks for current crashkernel in kernel boot
#
# Resolution:
#   Checks `proc/cmdline`
#
# Caveats:
#   Only supports Linux.
#

Facter.add(:crashkernel) do
  confine kernel: :linux
  setcode do
    crashkernel = false
    kernel_arguments = Facter.value(:kdump_kernel_arguments)
    if kernel_arguments && (kernel_arguments =~ %r{crashkernel=(\S+)})
      crashkernel = Regexp.last_match(1)
    end
    crashkernel
  end
end
