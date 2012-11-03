require "eventmachine"

module StatsD
  class FlushToGraphite
    DEFAULT_FLUSH_INTERVAL = 10.0
    DEFAULT_THRESHOLD_PERCENTAGES = [90.0]

    attr_writer :flush_interval, :threshold_percentages

    def initialize(socket)
      @flush_interval = DEFAULT_FLUSH_INTERVAL
      @threshold_percentages = DEFAULT_THRESHOLD_PERCENTAGES
      @socket = socket
    end

    def receive_stats(stats, collect_time = Time.now)
      stat_count = 0
      calc_start = Time.now
      timestamp  = "#{collect_time.to_i}\n"
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

      stats.timers.each do |key, values|
        values.sort!

        count = values.length
        min   = values.first
        max   = values.last

        sum      = values.reduce(:+)
        mean     = sum / count.to_f
        variance = values.reduce(0){|accum, x| accum + (x - mean) ** 2 } / (count - 1)
        stddev   = Math.sqrt(variance)

        @threshold_percentages.each do |threshold|
          threshold_label  = threshold.to_i
          threshold_index  = (threshold / 100 * count).round
          threshold_values = values[0...threshold_index]

          threshold_count  = threshold_values.length
          threshold_sum    = threshold_values.reduce(:+)
          threshold_mean   = threshold_sum / threshold_count.to_f
          threshold_max    = threshold_values.last

          lines << "stats.timers.#{key}.mean_#{threshold_label} #{threshold_mean} #{timestamp}"
          lines << "stats.timers.#{key}.sum_#{threshold_label} #{threshold_sum} #{timestamp}"
          lines << "stats.timers.#{key}.upper_#{threshold_label} #{threshold_max} #{timestamp}"
        end

        lines << "stats.timers.#{key}.count #{count} #{timestamp}"
        lines << "stats.timers.#{key}.lower #{min} #{timestamp}"
        lines << "stats.timers.#{key}.mean #{mean} #{timestamp}"
        lines << "stats.timers.#{key}.std #{stddev} #{timestamp}"
        lines << "stats.timers.#{key}.sum #{sum} #{timestamp}"
        lines << "stats.timers.#{key}.upper #{max} #{timestamp}"

        stat_count += 1
      end

      calc_time = ((Time.now - calc_start) * 1000).to_i # ms
      lines << "statsd.numStats #{stat_count} #{timestamp}"
      lines << "stats.statsd.graphiteStats.calculationtime #{calc_time} #{timestamp}"

      @socket.send_data lines.join
      @socket.close_connection_after_writing
    end
  end
end

