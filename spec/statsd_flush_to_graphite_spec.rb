require_relative '../lib/statsd/stat_aggregation'
require_relative '../lib/statsd/flush_to_graphite'

class FakeSocket
  attr_reader :last_message, :last_host, :last_port

  def send_data(message)
    @last_message = {}
    message.split("\n").each do |line|
      key, value, timestamp = line.split(" ")
      @last_message[key] = {key: key, value: value.to_f, timestamp: timestamp}
    end
  end

  def close_connection_after_writing; end
end

describe StatsD::FlushToGraphite do
  let(:backend) { StatsD::FlushToGraphite.new(socket) }
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

  it "takes into account the configured flush_interval" do
    backend.flush_interval = 1
    stats.counters.add("hello", 10)
    flush_stats

    last_message_key("stats.hello").should == 10
    last_message_key("stats_counts.hello").should == 10
    last_message_key("statsd.numStats").should == 1

    backend.flush_interval = 2
    stats.counters.add("hello", 10)
    flush_stats

    last_message_key("stats.hello").should == 10
    last_message_key("stats_counts.hello").should == 20
    last_message_key("statsd.numStats").should == 1
  end

  context "timers" do
    it "sends all the stats" do
      stats.timers.add("hello", 1000)
      flush_stats

      last_message_key("stats.timers.hello.count").should == 1
      last_message_key("stats.timers.hello.lower").should == 1000
      last_message_key("stats.timers.hello.mean").should == 1000
      last_message_key("stats.timers.hello.mean_90").should == 1000
      last_message_key("stats.timers.hello.std").should == 0
      last_message_key("stats.timers.hello.sum").should == 1000
      last_message_key("stats.timers.hello.sum_90").should == 1000
      last_message_key("stats.timers.hello.upper").should == 1000
      last_message_key("stats.timers.hello.upper_90").should == 1000
      last_message_key("statsd.numStats").should == 1
    end

    it "can calculate different threshold percentages" do
      backend.threshold_percentages = [50.0, 25.0]

      stats.timers.add("hello", 100)
      stats.timers.add("hello", 75)
      stats.timers.add("hello", 50)
      stats.timers.add("hello", 50)
      flush_stats

      last_message_key("stats.timers.hello.mean_50").should == 50
      last_message_key("stats.timers.hello.sum_50").should == 100
      last_message_key("stats.timers.hello.upper_50").should == 50

      last_message_key("stats.timers.hello.mean_25").should == 50
      last_message_key("stats.timers.hello.sum_25").should == 50
      last_message_key("stats.timers.hello.upper_25").should == 50
    end

    it "calculates the correct std, mean, max, and lower" do
      stats.timers.add("hello", 10)
      9.times { stats.timers.add("hello", 9) }

      [65, 63, 67, 64, 68, 62, 70, 66, 68, 67, 69, 71, 66, 65, 70].each do |n|
        stats.timers.add("world", n)
      end

      flush_stats

      last_message_key("stats.timers.hello.std").should be_within(0.0001).of(0.31622776601684)
      last_message_key("stats.timers.world.std").should be_within(0.0001).of(2.6583202716503)
      last_message_key("stats.timers.world.mean").should be_within(0.0001).of(66.733333333333)
      last_message_key("stats.timers.world.mean").should be_within(0.0001).of(66.733333333333)
      last_message_key("stats.timers.world.lower").should == 62
      last_message_key("stats.timers.world.upper").should == 71
      last_message_key("stats.timers.world.count").should == 15
    end
  end
end
