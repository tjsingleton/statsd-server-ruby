require "eventmachine"

module StatsD
  class Server
    def initialize(config)
      @config = config
    end

    def start
      @storage_parser_adapter = StoreParsedStats.new(StatAggregation.new)
      parser = Parser.new(@storage_parser_adapter)

      EM.open_datagram_socket(@config.host, @config.port, Connection, parser)
      EM.add_periodic_timer(@config.flush_interval, &method(:flush_stats))
    end

    def flush_stats
      old_storage = @storage_parser_adapter.swap_storage(StatAggregation.new)
      @config.backend.receive_stats(old_storage, Time.now)
    end
  end
end
