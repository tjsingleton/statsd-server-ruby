require_relative '../lib/statsd/store_parsed_stats'

describe StatsD::StoreParsedStats do
  it "adapts the parsers events to the storage" do
    counters = double
    storage = double counters: counters

    adapter = StatsD::StoreParsedStats.new(storage)
    counters.should_receive(:add).with("key", 1, 1.0)

    adapter.visit_Counter("key", 1, 1.0)
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
