module StatsD
  class StoreParsedStats
    def initialize(storage)
      @storage = storage
    end

    def swap_storage(new_storage)
      old_storage = @storage
      @storage = new_storage
      old_storage
    end

    def visit_Gauge(name, value)
      @storage.gauges[name] = value
    end

    def visit_Timer(name, value)
    end

    def visit_Counter(name, value, sample_rate)
      @storage.counters.add(name, value, sample_rate)
    end
  end
end
