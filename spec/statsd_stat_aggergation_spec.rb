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

    it "iterates through the counters" do
      expected = {}
      expected[key] = 1

      subject.counters.add(key, 1)

      counters = {}
      subject.counters.each {|key, value| counters[key] = value }

      counters.should == expected
    end
  end

  context "gauges" do
    let(:key) { "gauge.it" }

    it "can be set" do
      subject.gauges[key] = 1
      subject.gauges[key].should == 1

      subject.gauges[key] = 5
      subject.gauges[key].should == 5
    end

    it "iterates through the gauges" do
      expected = {}
      expected[key] = 1

      subject.gauges[key] = 1

      gauges = {}
      subject.gauges.each {|key, value| gauges[key] = value }

      gauges.should == expected
    end
  end

  context "timers" do
    let(:key) { "time.it"}

    it "collects the timing data" do
      subject.timers.add(key, 100)
      subject.timers.add(key, 200)

      subject.timers.get(key).should == [100, 200]
    end
  end
end
