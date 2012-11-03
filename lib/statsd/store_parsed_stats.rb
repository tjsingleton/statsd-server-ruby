module StatsD
  # A visitor for the parser. It adapts the parser messages to the storage interface.
  #
  # @see StatsD::Parser
  # @see StatsD::StatAggregation
  class StoreParsedStats
    # @param [StatsD::StatAggregation] storage provides storage for the stats
    def initialize(storage)
      @storage = storage
    end


    # @param [StatsD::StatAggregation] new_storage the replacement storage object
    # @yieldparam [StatsD::StatAggregation] old_storage the storage object being replaced
    def swap_storage(new_storage)
      yield(@storage) if block_given?
      @storage = new_storage
    end

    # @param [String] name
    # @param [Numeric] value
    def visit_Gauge(name, value)
      @storage.gauges[name] = value
    end

    # @param [String] name
    # @param [Numeric] value
    def visit_Timer(name, value)
      @storage.timers.add(name, value)
    end

    # @param [String] name
    # @param [Numeric] value
    # @param [Float] sample_rate
    def visit_Counter(name, value, sample_rate)
      @storage.counters.add(name, value, sample_rate)
    end
  end
end
