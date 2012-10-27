require_relative '../lib/statsd/store_parsed_stats'

describe StatsD::StoreParsedStats do
  context "adapting the parsers events to the storage" do
    it "counters" do
      counters = double
      storage = double counters: counters

      adapter = StatsD::StoreParsedStats.new(storage)
      counters.should_receive(:add).with("key", 1, 1.0)

      adapter.visit_Counter("key", 1, 1.0)
    end

    it "gauges" do
      gauges = {}
      storage = double gauges: gauges

      adapter = StatsD::StoreParsedStats.new(storage)
      adapter.visit_Gauge("key", 1)

      gauges.should eq("key" => 1)
    end
  end


  it "is able to swap the storage" do
    counters = double
    storage = double counters: counters
    new_counters = double
    new_storage = double counters: new_counters

    adapter = StatsD::StoreParsedStats.new(storage)

    counters.should_receive(:add).with("key", 1, 1.0)
    adapter.visit_Counter("key", 1, 1.0)

    old_storage = adapter.swap_storage(new_storage)
    old_storage.should eq(storage)

    new_counters.should_receive(:add).with("key", 1, 1.0)
    adapter.visit_Counter("key", 1, 1.0)
  end
end
