require 'ostruct'
require 'eventmachine'

require_relative '../lib/statsd'
require_relative '../lib/statsd/connection'
require_relative '../lib/statsd/stat_aggregation'
require_relative '../lib/statsd/store_parsed_stats'
require_relative '../lib/statsd/server'
require_relative '../lib/statsd/flush_to_graphite'

describe StatsD, "End to End" do
  HOST, PORT = '127.0.0.1', 8125

  class StatsD::Client
    def initialize(host, port)
      @host, @port = host, port
      @socket = UDPSocket.new
    end

    def increment(key, value = 1)
      send "#{key}:#{value}|c"
    end

    def gauge(key, value = 0)
      send "#{key}:#{value}|g"
    end

    private
    def send(str)
      @socket.send(str, 0, @host, @port)
    end
  end

  class StatsD::ServerDriver
    def initialize(config)
      @server = ::StatsD::Server.new(config)
    end

    def while_running
      EM.run do
        @server.start
        yield
      end
    end

    def timeout_in(seconds)
      EM.add_timer(seconds) { raise "Test timed out" }
    end

    # this is naive until the server is instrumented
    def after_next_flush
      timeout_in(0.20)
      EM.add_timer(0.15) { yield }
    end

    def shutdown
      EM.stop
    end
  end

  class FakeGraphite < EventMachine::Connection
    attr_reader :received

    def initialize
      @received = []
    end

    def receive_data(message)
      data = {}

      message.split("\n").each do |line|
        key, value, timestamp = line.split(" ")
        data[key] = value.to_f
      end

      @received << data
    end
  end

  let(:graphite_backend) { StatsD::FlushToGraphite.new(HOST, PORT + 1) }
  let(:config) { OpenStruct.new host: HOST, port: PORT, backend: graphite_backend }
  let(:client) { StatsD::Client.new HOST, PORT }
  let(:server) { StatsD::ServerDriver.new config  }

  before do
    config.flush_interval = graphite_backend.flush_interval = 0.10
  end

  it "incrementing a counter 1 time" do
    server.while_running do
      graphite = EM.open_datagram_socket(HOST, PORT + 1, FakeGraphite)

      server.after_next_flush do
        messages = graphite.received.last

        messages.should eq  "stats.end_to_end.test_1"                     => 10.0,
                            "stats_counts.end_to_end.test_1"              =>  1.0,
                            "statsd.numStats"                             =>  1.0,
                            "stats.statsd.graphiteStats.calculationtime"  =>  0.0

        server.shutdown
      end

      client.increment("end_to_end.test_1")
    end
  end

  it "setting a gauge" do
    server.while_running do
      graphite = EM.open_datagram_socket(HOST, PORT + 1, FakeGraphite)

      server.after_next_flush do
        messages = graphite.received.last

        messages.should eq  "stats.gauges.end_to_end.test_2"              =>  5.0,
                            "statsd.numStats"                             =>  1.0,
                            "stats.statsd.graphiteStats.calculationtime"  =>  0.0

        server.shutdown
      end

      client.gauge("end_to_end.test_2", 5)
    end
  end

  it "setting both a gauge and a counter" do
    server.while_running do
      graphite = EM.open_datagram_socket(HOST, PORT + 1, FakeGraphite)

      server.after_next_flush do
        messages = graphite.received.last

        messages.should eq  "stats.end_to_end.test_1"                     => 10.0,
                            "stats_counts.end_to_end.test_1"              =>  1.0,
                            "stats.gauges.end_to_end.test_2"              =>  5.0,
                            "statsd.numStats"                             =>  2.0,
                            "stats.statsd.graphiteStats.calculationtime"  =>  0.0

        server.shutdown
      end

      client.increment("end_to_end.test_1")
      client.gauge("end_to_end.test_2", 5)
    end
  end
end
