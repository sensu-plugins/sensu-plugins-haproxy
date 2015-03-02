## Sensu-Plugins-haproxy

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-haproxy.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-haproxy)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-haproxy.svg)](http://badge.fury.io/rb/sensu-plugins-haproxy)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-haproxy.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-haproxy)

## Functionality

## Files
 * bin/check-haproxy
 * bin/metrics-haproxy

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-haproxy -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-haproxy`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-haproxy' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-haproxy' do
  options('--prerelease')
  version '0.0.1.alpha.4'
end
```

## Notes

[1]:[https://travis-ci.org/sensu-plugins/sensu-plugins-haproxy]
[2]:[http://badge.fury.io/rb/sensu-plugins-haproxy]
[3]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy]
[4]:[https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy]
[5]:[https://gemnasium.com/sensu-plugins/sensu-plugins-haproxy]
