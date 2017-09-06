## Sensu-Plugins-haproxy

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-haproxy.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-haproxy)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-haproxy.svg)](http://badge.fury.io/rb/sensu-plugins-haproxy)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-haproxy)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-haproxy.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-haproxy)

## Functionality

## Files
 * bin/check-haproxy.rb
 * bin/metrics-haproxy.rb

## Usage


### Metrics

```
$ /opt/sensu/embedded/bin/metrics-haproxy.rb --help
Usage: /opt/sensu/embedded/bin/metrics-haproxy.rb (options)
    -f BACKEND1[,BACKEND2],          comma-separated list of backends to fetch stats from. Default is all backends
        --backends
    -c HOSTNAME|SOCKETPATH,          HAproxy web stats hostname or path to stats socket (required)
        --connect
    -a, --expose-all                 Expose all possible metrics, includes "--server-metrics", "--backends" will still in effect
    -p, --pass PASSWORD              HAproxy web stats password
    -q, --statspath STATUSPATH       HAproxy web stats path (the / will be prepended to the STATUSPATH e.g stats)
    -P, --port PORT                  HAproxy web stats port
    -r, --retries RETRIES            Number of times to retry fetching stats from haproxy before giving up.
    -i, --retry_interval SECONDS     Interval (seconds) between retries
    -s, --scheme SCHEME              Metric naming scheme, text to prepend to metric
        --server-metrics             Gathers additional frontend metrics, i.e. total requests
        --use-explicit-names         Use explicit names for frontend, backend, server, listener
        --use-haproxy-names          Use raw names as used in haproxy CSV format definition rather than human friendly names
    -S, --use-ssl                    Use SSL to connect to HAproxy web stats
    -u, --user USERNAME              HAproxy web stats username
$
```

## Installation

[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

## Notes
