# puppet-kdump

[![Build Status](https://travis-ci.org/treydock/puppet-kdump.png)](https://travis-ci.org/treydock/puppet-kdump)

## Overview

This module manages the kdump service.

## Usage

### Class: kdump

Use default actions of ensuring kdump is stopped

    class { 'kdump': }

Example of how to enable kdump

    class { 'kdump':
      enable => true,
    }

Example of changing the configuration for kdump.conf.

The *config_hashes* parameter may be an Array of Hashes or an Array of Strings.

    class { 'kdump':
      enable => true,
      config_hashes  => [
        {'path' => '/var/crash'},
        {'core_collector' => 'makedumpfile -c --message-level 1 -d 31'},
        {'kdump_post' => '/var/crash/scripts/kdump-post.sh'},
      ],
    }

Using an Array of Strings

    class { 'kdump':
      service_ensure => 'running',
      service_enable => true,
      config_hashes  => [
        'path /var/crash',
        'core_collector makedumpfile -c --message-level 1 -d 31',
        'kdump_post /var/crash/scripts/kdump-post.sh',
      ],
    }

## Compatibility

Tested using

* CentOS 5.9
* CentOS 6.4

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake ci

If you have Vagrant >= 1.2.0 installed you can run system tests

    bundle exec rake spec:system

## Further Information

* https://www.kernel.org/doc/Documentation/kdump/kdump.txt
