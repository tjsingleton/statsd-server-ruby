require_relative "../lib/statsd/stat_aggregation"

describe StatsD::StatAggregation do
  context "counters" do
    let(:key) { "count.it" }

    it "can be incremented" do
      subject.counters.add(key, 2)
      subject.counters.get(key).should == 2

      subject.counters.add(key, 10)
      subject.counters.get(key).should == 12
    end

    it "can be decremented" do
      subject.counters.add(key, -1)
      subject.counters.get(key).should == -1

      subject.counters.add(key, -100)
      subject.counters.get(key).should == -101
    end

    it "adjusts the value based on the sample rate" do
      subject.counters.add(key, 50, 0.5)
      subject.counters.get(key).should == 100
    end
  end
end
