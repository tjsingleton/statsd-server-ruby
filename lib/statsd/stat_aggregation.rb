module StatsD
  class CounterCollection
    def initialize
      @storage = Hash.new {|h, k| h[k] = 0.0 }
    end

    def add(key, value = 1, sample_rate = 1.0)
      @storage[key] += value * (1.0 / sample_rate)
    end

    def get(key)
      @storage[key]
    end

    def each(*args, &block)
      @storage.each(*args, &block)
    end
  end

  class StatAggregation
    attr_reader :counters, :gauges

    def initialize
      @counters = CounterCollection.new
      @gauges   = {}
    end
  end
end
