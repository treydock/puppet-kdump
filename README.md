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
      service_ensure => 'running',
      service_enable => true,
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
