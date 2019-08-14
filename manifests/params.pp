# @summary The kdump configuration settings.
# @api private
class kdump::params {

  case $::osfamily {
    'RedHat': {
      $package_name       = 'kexec-tools'
      $service_name       = 'kdump'
      $service_hasstatus  = true
      $service_hasrestart = true
      $config_path        = '/etc/kdump.conf'

      $config_defaults = {
        'path'              => '/var/crash',
        'core_collector'    => 'makedumpfile -c --message-level 1 -d 31',
        'raw'               => 'UNSET',
        'nfs'               => 'UNSET',
        'nfs4'              => 'UNSET',
        'ssh'               => 'UNSET',
        'ext4'              => 'UNSET',
        'ext3'              => 'UNSET',
        'ext2'              => 'UNSET',
        'minix'             => 'UNSET',
        'btrfs'             => 'UNSET',
        'xfs'               => 'UNSET',
        'link_delay'        => 'UNSET',
        'kdump_post'        => 'UNSET',
        'kdump_pre'         => 'UNSET',
        'extra_bins'        => 'UNSET',
        'extra_modules'     => 'UNSET',
        'options'           => 'UNSET',
        'blacklist'         => 'UNSET',
        'sshkey'            => 'UNSET',
        'default'           => 'UNSET',
        'debug_mem_level'   => 'UNSET',
        'force_rebuild'     => 'UNSET',
      }

      if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
        $kernel_parameter_provider = 'grub2'
      } else {
        $kernel_parameter_provider = 'grub'
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily}, module ${module_name} only support osfamily RedHat")
    }
  }

}