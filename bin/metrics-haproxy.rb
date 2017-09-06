#! /usr/bin/env ruby
#
#   metrics-haproxy.rb
#
# DESCRIPTION:
#   If you are occassionally seeing "nil output" from this check, make sure you have
#   sensu-plugin >= 0.1.7. This will provide a better error message.
#
# OUTPUT:
#   metric data, etc
#
# PLATFORMS:
#   Linux, Windows, BSD, Solaris, etc
#
# DEPENDENCIES:
#   gem: sensu-plugin
#
# USAGE:
#
# LICENSE:
#   Pete Shima <me@peteshima.com>, Joe Miller <https://github.com/joemiller>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'net/http'
require 'net/https'
require 'socket'
require 'csv'
require 'uri'

#
# HA Proxy Metrics
#
class HAProxyMetrics < Sensu::Plugin::Metric::CLI::Graphite
  # Check http://cbonte.github.io/haproxy-dconv/1.7/management.html#9.1 for
  # haproxy stats CSV format.

  TYPE_FRONTEND = '0'.freeze
  TYPE_BACKEND = '1'.freeze
  TYPE_SERVER = '2'.freeze
  TYPE_LISTENER = '3'.freeze
  # All fields are listed here for ease of long term maintenance.
  # Format: field_index => %w(haproxy-name friendly-name)
  CSV_FIELDS = {
    0 => %w(pxname proxy_name),
    1 => %w(svname service_name),
    2 => %w(qcur queued_requests_current),
    3 => %w(qmax queued_requests_max),
    4 => %w(scur session_current),
    5 => %w(smax session_max),
    6 => %w(slim session_limit),
    7 => %w(stot session_total),
    8 => %w(bin bytes_in),
    9 => %w(bout bytes_out),
    10 => %w(dreq request_denied_security),
    11 => %w(dresp response_denied_security),
    12 => %w(ereq request_errors),
    13 => %w(econ connection_errors),
    14 => %w(eresp response_errors),
    15 => %w(wretr warning_retries),
    16 => %w(wredis warning_redispatched),
    17 => %w(status status),
    18 => %w(weight weight),
    19 => %w(act servers_active),
    20 => %w(bck servers_backup),
    21 => %w(chkfail healthcheck_failed),
    22 => %w(chkdown healthcheck_transitions),
    23 => %w(lastchg healthcheck_seconds_since_change),
    24 => %w(downtime healthcheck_downtime),
    25 => %w(qlimit server_queue_limit),
    26 => %w(pid process_id),
    27 => %w(iid proxy_id),
    28 => %w(sid server_id),
    29 => %w(throttle server_throttle_percent),
    30 => %w(lbtot server_selected),
    31 => %w(tracked tracked_server_id),
    32 => %w(type type),
    33 => %w(rate session_rate),
    34 => %w(rate_lim session_rate_limit),
    35 => %w(rate_max session_rate_max),
    36 => %w(check_status check_status),
    37 => %w(check_code check_code),
    38 => %w(check_duration healthcheck_duration),
    39 => %w(hrsp_1xx response_1xx),
    40 => %w(hrsp_2xx response_2xx),
    41 => %w(hrsp_3xx response_3xx),
    42 => %w(hrsp_4xx response_4xx),
    43 => %w(hrsp_5xx response_5xx),
    44 => %w(hrsp_other response_other),
    45 => %w(hanafail failed_healthcheck_details),
    46 => %w(req_rate requests_per_second),
    47 => %w(req_rate_max requests_per_second_max),
    48 => %w(req_tot requests_total),
    49 => %w(cli_abrt trasfer_aborts_client),
    50 => %w(srv_abrt trasfer_aborts_server),
    51 => %w(comp_in compressor_in),
    52 => %w(comp_out compressor_out),
    53 => %w(comp_byp compressor_bytes),
    54 => %w(comp_rsp compressor_responses),
    55 => %w(lastsess session_last_assigned_seconds),
    56 => %w(last_chk healthcheck_contents),
    57 => %w(last_agt agent_check_contents),
    58 => %w(qtime queue_time),
    59 => %w(ctime connect_time),
    60 => %w(rtime response_time),
    61 => %w(ttime average_time),
    62 => %w(agent_status agent_status),
    63 => %w(agent_code agent_code),
    64 => %w(agent_duration agent_duration),
    65 => %w(check_desc check_desc),
    66 => %w(agent_desc agent_desc),
    67 => %w(check_rise check_rise),
    68 => %w(check_fall check_fall),
    69 => %w(check_health check_health),
    70 => %w(agent_rise agent_rise),
    71 => %w(agent_fall agent_fall),
    72 => %w(agent_health agent_health),
    73 => %w(addr address),
    74 => %w(cookie cookie),
    75 => %w(mode mode),
    76 => %w(algo algorithm),
    77 => %w(conn_rate conn_rate),
    78 => %w(conn_rate_max conn_rate_max),
    79 => %w(conn_tot conn_tot),
    80 => %w(intercepted requests_intercepted),
    81 => %w(dcon requests_denied_connection),
    82 => %w(dses requests_denied_session)
  }.freeze
  NON_NUMERIC_FIELDS = [0, 1, 17, 26, 27, 28, 31, 32, 36, 37, 45, 56, 57, 62, 63, 65, 66, 73, 74, 75, 76].freeze

  option :connection,
         short: '-c HOSTNAME|SOCKETPATH',
         long: '--connect HOSTNAME|SOCKETPATH',
         description: 'HAproxy web stats hostname or path to stats socket',
         required: true

  option :port,
         short: '-P PORT',
         long: '--port PORT',
         description: 'HAproxy web stats port',
         default: '80'

  option :path,
         short: '-q STATUSPATH',
         long: '--statspath STATUSPATH',
         description: 'HAproxy web stats path (the / will be prepended to the STATUSPATH e.g stats)',
         default: '/'

  option :username,
         short: '-u USERNAME',
         long: '--user USERNAME',
         description: 'HAproxy web stats username'

  option :password,
         short: '-p PASSWORD',
         long: '--pass PASSWORD',
         description: 'HAproxy web stats password'

  option :scheme,
         description: 'Metric naming scheme, text to prepend to metric',
         short: '-s SCHEME',
         long: '--scheme SCHEME',
         default: "#{Socket.gethostname}.haproxy"

  option :use_ssl,
         description: 'Use SSL to connect to HAproxy web stats',
         short: '-S',
         long: '--use-ssl',
         boolean: true,
         default: false

  option :backends,
         description: 'comma-separated list of backends to fetch stats from. Default is all backends',
         short: '-f BACKEND1[,BACKEND2]',
         long: '--backends BACKEND1[,BACKEND2]',
         proc: proc { |l| l.split(',') },
         default: [] # an empty list means show all backends

  option :server_metrics,
         description: 'Gathers additional frontend metrics, i.e. total requests',
         boolean: true,
         long: '--server-metrics',
         default: false

  option :retries,
         description: 'Number of times to retry fetching stats from haproxy before giving up.',
         short: '-r RETRIES',
         long: '--retries RETRIES',
         default: 3,
         proc: proc(&:to_i)

  option :retry_interval,
         description: 'Interval (seconds) between retries',
         short: '-i SECONDS',
         long: '--retry_interval SECONDS',
         default: 1,
         proc: proc(&:to_i)

  option :expose_all,
         description: 'Expose all possible metrics, includes "--server-metrics", "--backends" will still in effect',
         short: '-a',
         long: '--expose-all',
         boolean: true,
         default: false

  option :use_haproxy_names,
         description: 'Use raw names as used in haproxy CSV format definition rather than human friendly names',
         long: '--use-haproxy-names',
         boolean: true,
         default: false

  option :use_explicit_names,
         description: 'Use explicit names for frontend, backend, server, listener',
         long: '--use-explicit-names',
         boolean: true,
         default: false

  def acquire_stats
    uri = URI.parse(config[:connection])

    if uri.is_a?(URI::Generic) && File.socket?(uri.path)
      socket = UNIXSocket.new(config[:connection])
      socket.puts('show stat')
      out = socket.read
      socket.close
    else
      res = Net::HTTP.start(config[:connection], config[:port], use_ssl: config[:use_ssl]) do |http|
        req = Net::HTTP::Get.new("/#{config[:path]};csv;norefresh")
        unless config[:username].nil?
          req.basic_auth config[:username], config[:password]
        end
        http.request(req)
      end
      out = res.body
    end
    return out
  rescue
    return nil
  end

  def render_output(type, pxname, svname, index, value)
    return if value.nil?
    field_index = config[:use_haproxy_names] ? 0 : 1
    field_name = CSV_FIELDS[index][field_index]
    if config[:use_explicit_names]
      if type == TYPE_FRONTEND
        output "#{config[:scheme]}.frontend.#{pxname}.#{field_name}", value
      elsif type == TYPE_BACKEND
        output "#{config[:scheme]}.backend.#{pxname}.#{field_name}", value
      elsif type == TYPE_SERVER
        output "#{config[:scheme]}.backend.#{pxname}.server.#{svname}.#{field_name}", value
      elsif type == TYPE_LISTENER
        output "#{config[:scheme]}.listener.#{pxname}.#{svname}.#{field_name}", value
      end
    else
      if type == TYPE_BACKEND # rubocop:disable IfInsideElse
        output "#{config[:scheme]}.#{pxname}.#{field_name}", value
      else
        output "#{config[:scheme]}.#{pxname}.#{svname}.#{field_name}", value
      end
    end
  end

  def run
    out = nil
    1.upto(config[:retries]) do |_i|
      out = acquire_stats
      break unless out.to_s.length.zero?
      sleep(config[:retry_interval])
    end

    if out.to_s.length.zero?
      warning "Unable to fetch stats from haproxy after #{config[:retries]} attempts"
    end

    up_by_backend = {}
    parsed = CSV.parse(out)
    parsed.shift
    parsed.each do |line|
      pxname = line[0]
      svname = line[1]
      type = line[32]

      if config[:backends].length > 0
        next unless config[:backends].include? line[0]
      end

      indices = []
      if config[:expose_all]
        indices = CSV_FIELDS.keys - NON_NUMERIC_FIELDS
      elsif type == TYPE_BACKEND
        indices = [4, 7, 8, 9, 13, 15, 16, 39, 40, 41, 42, 43, 44, 46, 47, 58, 59, 60, 61]
      elsif config[:server_metrics]
        indices = [4, 7, 46, 47, 48]
      end
      indices.each { |i| render_output type, pxname, svname, i, line[i] }

      if type == TYPE_SERVER
        up_by_backend[pxname] ||= 0
        up_by_backend[pxname] += line[17].start_with?('UP') ? 1 : 0
      end
    end

    up_by_backend.each_pair do |backend, count|
      if config[:use_explicit_names]
        output "#{config[:scheme]}.backend.#{backend}.num_up", count
      else
        output "#{config[:scheme]}.#{backend}.num_up", count
      end
    end

    ok
  end
end
