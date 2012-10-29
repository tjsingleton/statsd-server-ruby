require_relative '../lib/statsd/stat_aggregation'
require_relative '../lib/statsd/flush_to_graphite'

class FakeSocket
  attr_reader :last_message, :last_host, :last_port

  def send(message, _, host, port)
    @host = host
    @port = port

    @last_message = {}
    message.split("\n").each do |line|
      key, value, timestamp = line.split(" ")
      @last_message[key] = {key: key, value: value.to_f, timestamp: timestamp}
    end
  end
end

describe StatsD::FlushToGraphite do
  let(:backend) { StatsD::FlushToGraphite.new('host', 'port', socket) }
  let(:socket)  { FakeSocket.new }
  let(:stats)   { StatsD::StatAggregation.new }

  def last_message_key(key, part = :value)
    socket.last_message.fetch(key).fetch(part)
  end

  def flush_stats
    backend.receive_stats(stats)
  end

  it "sends the number of stats and calculation time" do
    flush_stats

    last_message_key("statsd.numStats").should == 0
    last_message_key("stats.statsd.graphiteStats.calculationtime").should be_within(0.001).of(0)
  end

  it "sends a gauge" do
    stats.gauges["hello"] = 1
    stats.gauges["hello.other"] = 5
    flush_stats

    last_message_key("stats.gauges.hello").should == 1
    last_message_key("stats.gauges.hello.other").should == 5
    last_message_key("statsd.numStats").should == 2
  end

  it "sends a counter" do
    stats.counters.add("hello", 10)
    flush_stats

    last_message_key("stats.hello").should == 1
    last_message_key("stats_counts.hello").should == 10
    last_message_key("statsd.numStats").should == 1
  end

  it "takes into account the configured flush_interval when " do
    backend.flush_interval = 1
    stats.counters.add("hello", 10)
    flush_stats

    last_message_key("stats.hello").should == 10
    last_message_key("stats_counts.hello").should == 10
    last_message_key("statsd.numStats").should == 1
  end
end
