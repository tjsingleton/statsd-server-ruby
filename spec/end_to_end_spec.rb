require 'ostruct'
require 'em/protocols/line_protocol'

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

    def timing(key, value)
      send "#{key}:#{value}|ms"
    end

    private
    def send(str)
      @socket.send(str, 0, @host, @port)
    end
  end

  class FakeGraphite < EventMachine::Connection
    def initialize(server)
      @server = server
      @buffer = []
    end

    def receive_data(data)
      @buffer << data
    end

    def unbind
      messages = @buffer.join()

      messages.split("\n").reject(&:empty?).each do |line|
        key, value, timestamp = line.split(" ")
        @server.messages[key] = value.to_f
      end

      @server.after_next_flush!
    end
  end

  class StatsD::ServerDriver < StatsD::Server
    attr_reader :messages

    def while_running(&block)
      EM.run do
        @messages = {}
        EM.start_server(@config.graphite_host, @config.graphite_port, FakeGraphite, self)

        start
        timeout_in(@config.flush_interval * 1.75)

        block.call
      end
    end

    def timeout_in(seconds)
      EM.add_timer(seconds) { raise "Test timed out" }
    end

    # this is naive until the server is instrumented
    def flush_and_shutdown(&block)
      @after_next_flush = -> { block.call; shutdown }
    end

    def after_next_flush!
      @after_next_flush.call
    end

    def shutdown
      EM.stop
    end
  end

  let(:config) { OpenStruct.new host: HOST, port: PORT, graphite_host: HOST, graphite_port: PORT + 1, flush_interval: 0.020 }
  let(:client) { StatsD::Client.new HOST, PORT }
  let(:server) { StatsD::ServerDriver.new config  }

  def messages
    server.messages
  end

  it "incrementing a counter once" do
    server.while_running do
      server.flush_and_shutdown do
        messages.should eq "stats.end_to_end.test_1"                     => 2500.0,
                           "stats_counts.end_to_end.test_1"              =>   50.0,
                           "statsd.numStats"                             =>    1.0,
                           "stats.statsd.graphiteStats.calculationtime"  =>    0.0

        server.shutdown
      end

      client.increment("end_to_end.test_1", 50)
    end
  end

  it "setting a gauge" do
    server.while_running do
      server.flush_and_shutdown do
        messages.should eq "stats.gauges.end_to_end.test_2"              =>  5.0,
                           "statsd.numStats"                             =>  1.0,
                           "stats.statsd.graphiteStats.calculationtime"  =>  0.0
      end

      client.gauge("end_to_end.test_2", 5)
    end
  end

  it "setting both a gauge and a counter" do
    server.while_running do
      server.flush_and_shutdown do
        messages.should eq "stats.end_to_end.test_1"                     => 2500.0,
                           "stats_counts.end_to_end.test_1"              =>   50.0,
                           "stats.gauges.end_to_end.test_2"              =>    5.0,
                           "statsd.numStats"                             =>    2.0,
                           "stats.statsd.graphiteStats.calculationtime"  =>    0.0
      end

      client.increment("end_to_end.test_1", 50)
      client.gauge("end_to_end.test_2", 5)
    end
  end

  it "setting a timer" do
    server.while_running do
      server.flush_and_shutdown do
        messages.delete("stats.statsd.graphiteStats.calculationtime").should_not be_nil
        messages.should eq "stats.timers.end_to_end.test_3.mean_90"      => 10.0,
                           "stats.timers.end_to_end.test_3.upper_90"     => 10.0,
                           "stats.timers.end_to_end.test_3.sum_90"       => 10.0,
                           "stats.timers.end_to_end.test_3.std"          =>  0.0,
                           "stats.timers.end_to_end.test_3.upper"        => 10.0,
                           "stats.timers.end_to_end.test_3.lower"        => 10.0,
                           "stats.timers.end_to_end.test_3.count"        =>  1.0,
                           "stats.timers.end_to_end.test_3.sum"          => 10.0,
                           "stats.timers.end_to_end.test_3.mean"         => 10.0,
                           "statsd.numStats"                             =>  1.0
      end

      client.timing("end_to_end.test_3", 10)
    end
  end
end
