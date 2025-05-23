# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v2.0.4](https://github.com/treydock/puppet-kdump/tree/v2.0.4) (2025-05-21)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v2.0.3...v2.0.4)

### Fixed

- Ensure EL9 fully can disable to crashkernel [\#29](https://github.com/treydock/puppet-kdump/pull/29) ([treydock](https://github.com/treydock))

## [v2.0.3](https://github.com/treydock/puppet-kdump/tree/v2.0.3) (2025-05-19)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v2.0.2...v2.0.3)

### Fixed

- Fix disabling crash kernel for EL9 [\#28](https://github.com/treydock/puppet-kdump/pull/28) ([treydock](https://github.com/treydock))

## [v2.0.2](https://github.com/treydock/puppet-kdump/tree/v2.0.2) (2025-04-28)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v2.0.1...v2.0.2)

### Fixed

- Fix RHEL9 default for crashkernel [\#27](https://github.com/treydock/puppet-kdump/pull/27) ([treydock](https://github.com/treydock))

## [v2.0.1](https://github.com/treydock/puppet-kdump/tree/v2.0.1) (2024-01-09)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v2.0.0...v2.0.1)

### Fixed

- Fix merge function stdlib deprecation message [\#25](https://github.com/treydock/puppet-kdump/pull/25) ([ynnckvdv](https://github.com/ynnckvdv))

## [v2.0.0](https://github.com/treydock/puppet-kdump/tree/v2.0.0) (2023-09-20)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v1.0.0...v2.0.0)

### Changed

- Update Debian and Ubuntu support [\#24](https://github.com/treydock/puppet-kdump/pull/24) ([treydock](https://github.com/treydock))
- BREAKING: Updates, Drop Puppet 6 and add Puppet 8 support [\#21](https://github.com/treydock/puppet-kdump/pull/21) ([treydock](https://github.com/treydock))

### Added

- Support EL9 [\#23](https://github.com/treydock/puppet-kdump/pull/23) ([treydock](https://github.com/treydock))
- Update module dependencies [\#22](https://github.com/treydock/puppet-kdump/pull/22) ([treydock](https://github.com/treydock))

## [v1.0.0](https://github.com/treydock/puppet-kdump/tree/v1.0.0) (2022-03-19)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v0.4.1...v1.0.0)

### Changed

- Major updates [\#17](https://github.com/treydock/puppet-kdump/pull/17) ([treydock](https://github.com/treydock))

### Added

- Add manage\_kernel\_parameter parameter [\#18](https://github.com/treydock/puppet-kdump/pull/18) ([treydock](https://github.com/treydock))

## [v0.4.1](https://github.com/treydock/puppet-kdump/tree/v0.4.1) (2019-08-19)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v0.4.0...v0.4.1)

### Fixed

- Increase upper bound of stdlib module dependency [\#15](https://github.com/treydock/puppet-kdump/pull/15) ([treydock](https://github.com/treydock))

## [v0.4.0](https://github.com/treydock/puppet-kdump/tree/v0.4.0) (2019-08-19)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/v0.3.0...v0.4.0)

### Changed

- Change facts used by module [\#13](https://github.com/treydock/puppet-kdump/pull/13) ([treydock](https://github.com/treydock))

### Added

- Only start kdump service if crashkernel kernel argument present [\#14](https://github.com/treydock/puppet-kdump/pull/14) ([treydock](https://github.com/treydock))

## [v0.3.0](https://github.com/treydock/puppet-kdump/tree/v0.3.0) (2019-08-19)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/0.2.0...v0.3.0)

### Changed

- Drop Puppet 4 support [\#10](https://github.com/treydock/puppet-kdump/pull/10) ([treydock](https://github.com/treydock))

### Added

- Debian/Ubuntu support [\#12](https://github.com/treydock/puppet-kdump/pull/12) ([treydock](https://github.com/treydock))
- Use module Hiera data [\#11](https://github.com/treydock/puppet-kdump/pull/11) ([treydock](https://github.com/treydock))
- Convert module to PDK [\#9](https://github.com/treydock/puppet-kdump/pull/9) ([treydock](https://github.com/treydock))

## [0.2.0](https://github.com/treydock/puppet-kdump/tree/0.2.0) (2019-04-22)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/0.1.1...0.2.0)

### Added

- ability to specify different service parameters [\#8](https://github.com/treydock/puppet-kdump/pull/8) ([lukebigum](https://github.com/lukebigum))

## [0.1.1](https://github.com/treydock/puppet-kdump/tree/0.1.1) (2019-04-02)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/treydock/puppet-kdump/tree/0.1.0) (2019-04-02)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/0.0.1...0.1.0)

### Changed

- Drop support for EL5 [\#5](https://github.com/treydock/puppet-kdump/pull/5) ([treydock](https://github.com/treydock))

### Added

- Updated to work with Puppet 4.10 and later [\#3](https://github.com/treydock/puppet-kdump/pull/3) ([jeannegreulich](https://github.com/jeannegreulich))

## [0.0.1](https://github.com/treydock/puppet-kdump/tree/0.0.1) (2015-07-31)

[Full Changelog](https://github.com/treydock/puppet-kdump/compare/3b2e330fd5779b55a0a2f35c84fbe9b8e1112124...0.0.1)

### Added

- CentOS 7 compatibility [\#1](https://github.com/treydock/puppet-kdump/pull/1) ([tangestani](https://github.com/tangestani))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
