#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
- added fail on missing service flag

## [1.0.0] - 2016-12-08
### Added
- added names of the failed backends to check-haproxy.rb status
- added check status of failed backends to check-haproxy.rb output
- support for Ruby 2.3.0

### Changed
- check-haproxy.rb: Services without a health check should not be considered failed
- Update to rubocop 0.40 and cleanup

### Removed
- Ruby 1.9.3 support

## [0.1.1] - 2016-04-23
### Added
- added session_current to output for server_metrics

## [0.1.0] - 2016-03-04
### Added
- added `num_up` metric for each backend set showing the number of available backends
- added flags to check session availability per backend

### Changed
- update rubocop rules and fix errors

## [0.0.5] - 2015-11-26
### Changed
- alert on min server count
- fixed reporting of empty values

## [0.0.4] - 2015-08-04
### Changed
- general cleanup

## [0.0.3] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## [0.0.2] - 2015-06-02
### Fixed
- added binstubs

### Changed
- removed cruft from /lib

## 0.0.1 - 2015-05-21
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/1.0.0...HEAD
[1.0.0]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.1.1...1.0.0
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.1.0...0.1.1
[0.1.0]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.0.5...0.1.0
[0.0.5]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.0.4...0.0.5
[0.0.4]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.0.3...0.0.4
[0.0.3]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.0.2...0.0.3
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-haproxy/compare/0.0.1...0.0.2
