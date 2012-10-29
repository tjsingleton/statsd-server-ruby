module StatsD
  class FlushToGraphite
    DEFAULT_FLUSH_INTERVAL = 10.0
    DEFAULT_THRESHOLD_PERCENTAGES = [90.0]

    attr_writer :flush_interval, :threshold_percentages

    def initialize(host, port, socket = UDPSocket.new)
      @host, @port = host, port
      @socket = socket
      @flush_interval = DEFAULT_FLUSH_INTERVAL
      @threshold_percentage = DEFAULT_THRESHOLD_PERCENTAGES
    end

    def receive_stats(stats, collect_time = Time.now)
      stat_count = 0
      calc_start = Time.now
      timestamp  = collect_time.to_i
      lines      = []

      stats.counters.each do |key, value|
        value_per_second = value / @flush_interval.to_f

        lines << "stats.#{key} #{value_per_second} #{timestamp}"
        lines << "stats_counts.#{key} #{value} #{timestamp}"

        stat_count += 1
      end

      stats.gauges.each do |key, value|
        lines << "stats.gauges.#{key} #{value} #{timestamp}"

        stat_count += 1
      end

      calc_time = ((Time.now - calc_start) * 1000).to_i # ms
      lines << "statsd.numStats #{stat_count} #{timestamp}"
      lines << "stats.statsd.graphiteStats.calculationtime #{calc_time} #{timestamp}"

      @socket.send(lines.join("\n"), 0, @host, @port)
    end
  end
end

