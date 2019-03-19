source ENV['GEM_SOURCE'] || "https://rubygems.org"

group :development, :test do
  gem 'rake',                     :require => false
  gem 'rspec',                    :require => false
  gem 'rspec-puppet',             :require => false
  gem 'rspec-puppet-facts',       :require => false
  gem 'hiera-puppet-helper',      :require => false
  gem 'puppetlabs_spec_helper',   :require => false
  gem 'puppet-lint',              :require => false
end

group :system_tests do
  gem 'beaker',                       :require => false
  gem 'beaker-rspec',                 :require => false
  gem 'beaker-vagrant',               :require => false
  gem 'beaker-module_install_helper', :require => false
  gem 'beaker-puppet_install_helper', :require => false
  gem 'serverspec',                   :require => false
  gem 'pry',                          :require => false unless RUBY_VERSION =~ /^1.8/
end

if facterversion = ENV['FACTER_GEM_VERSION']
  gem 'facter', facterversion, :require => false
else
  gem 'facter', :require => false
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', :require => false
end

# vim:ft=ruby
