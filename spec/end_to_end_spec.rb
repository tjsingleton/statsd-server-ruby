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
    end

    def flush_stats(stats)

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
      EM.add_timer(seconds) do
        raise "Test timed out"
      end
    end

    def counter(key)
    end

    def after_next_message
    end

    def after_next_flush
    end
  end

  class FakeGraphite
    def initialize(host, port)
    end

    def last_message
    end
  end


  let(:config) { OpenStruct.new host: HOST, port: PORT, flush_interval: 2, backend: graphite_backend }
  let(:client) { StatsD::Client.new HOST, PORT }
  let(:server) { StatsD::ServerDriver.new config  }
  let(:graphite) { FakeGraphite.new HOST, PORT + 1 }
  let(:graphite_backend) { StatsD::FlushToGraphite.new HOST, PORT + 1 }


  pending "incrementing a counter 1 time" do
    server.while_running do
      server.timeout_in(3)

      server.after_next_message do
        server.counter("end_to_end.test_1").should eq(1)
      end

      server.after_next_flush do
        message = graphite.last_message
        message.key.should eq("end_to_end.test_1")
        message.value.should eq(1)
        message.timestamp.should be_within(10.0).of(Time.now.to_i)

        server.shutdown
      end

      client.increment("end_to_end.test_1")
    end
  end
end
