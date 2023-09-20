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

## Reference

[http://treydock.github.io/puppet-kdump/](http://treydock.github.io/puppet-kdump/)

## Development

### Testing

Testing requires the following dependencies:

* rake
* bundler

Install gem dependencies

    bundle install

Run unit tests

    bundle exec rake spec

## Further Information

* https://www.kernel.org/doc/Documentation/kdump/kdump.txt
