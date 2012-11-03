require "eventmachine"

require_relative "../statsd" # parser
require_relative "store_parsed_stats"
require_relative "stat_aggregation"
require_relative "connection"

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
      flush_time = Time.now

      @storage_parser_adapter.swap_storage(StatAggregation.new) do |old_storage|
        EM.connect(@config.graphite_host, @config.graphite_port) do |socket|
          backend = StatsD::FlushToGraphite.new(socket)
          backend.flush_interval= @config.flush_interval
          backend.receive_stats(old_storage, flush_time)
        end
      end
    end
  end
end
