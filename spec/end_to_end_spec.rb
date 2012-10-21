require 'ostruct'
require 'eventmachine'

require_relative '../lib/statsd'
require_relative '../lib/statsd/connection'
require_relative '../lib/statsd/stat_aggregation'
require_relative '../lib/statsd/store_parsed_stats'
require_relative '../lib/statsd/server'

describe StatsD, "End to End" do
  HOST, PORT = '127.0.0.1', 8125

  class StatsD::FlushToGraphite
    def initialize(host, port)
      @host, @port = host, port
      @socket = UDPSocket.new
    end

    def flush_stats(stats)
      lines = []
      timestamp  = Time.now.to_i

      stats.counters.each {|key, value| lines.push "#{key} #{value} #{timestamp}" }
      @socket.send(lines.join("\n"), 0, @host, @port)
    end
  end

  class StatsD::Client
    def initialize(host, port)
      @host, @port = host, port
      @socket = UDPSocket.new
    end

    def increment(key, change = 1)
      @socket.send("#{key}:#{change}|c", 0, @host, @port)
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
    def initialize
      @received = []
    end

    def receive_data(message)
      message.split("\n").each do |line|
        key, value, timestamp = line.split(" ")
        @received << OpenStruct.new(key: key, value: value.to_i, timestamp: timestamp.to_i)
      end
    end

    def last_message
      @received.last
    end
  end

  let(:graphite_backend) { StatsD::FlushToGraphite.new(HOST, PORT + 1) }
  let(:config) { OpenStruct.new host: HOST, port: PORT, flush_interval: 0.05, backend: graphite_backend }
  let(:client) { StatsD::Client.new HOST, PORT }
  let(:server) { StatsD::ServerDriver.new config  }


  it "incrementing a counter 1 time" do
    server.while_running do
      graphite = EM.open_datagram_socket(HOST, PORT + 1, FakeGraphite)

      server.after_next_flush do
        message = graphite.last_message
        message.key.should eq("end_to_end.test_1")
        message.value.should eq(1)
        message.timestamp.to_i.should be_within(10.0).of(Time.now.to_i)

        server.shutdown
      end

      client.increment("end_to_end.test_1")
    end
  end
end
