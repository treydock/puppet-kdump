# puppet-kdump

[![Puppet Forge](http://img.shields.io/puppetforge/v/treydock/kdump.svg)](https://forge.puppetlabs.com/treydock/kdump)
[![Build Status](https://travis-ci.org/treydock/puppet-kdump.svg?branch=master)](https://travis-ci.org/treydock/puppet-kdump)

## Overview

This module manages the kdump service.

## Usage

Use default actions of ensuring kdump is stopped

    class { 'kdump': }

Example of how to enable kdump

    class { 'kdump':
      enable => true,
    }

Example of changing the configuration for kdump.conf.

The *config_overrides* is a hash that can be used to override the default configuration.  Below is the default config_overrides.

    class { 'kdump':
      enable => true,
      config_overrides => {
        'path' => '/var/crash',
        'core_collector' => 'makedumpfile -c --message-level 1 -d 31',
      },
    }

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake spec

If you have Vagrant >= 1.2.0 installed you can run system tests

    BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_set=centos-7-vagrant bundle exec rake beaker
    BEAKER_PUPPET_COLLECTION=puppet6 BEAKER_set=centos-7-vagrant bundle exec rake beaker
    BEAKER_PUPPET_COLLECTION=puppet5 BEAKER_set=centos-6-vagrant bundle exec rake beaker
    BEAKER_PUPPET_COLLECTION=puppet6 BEAKER_set=centos-6-vagrant bundle exec rake beaker

## Further Information

* https://www.kernel.org/doc/Documentation/kdump/kdump.txt
