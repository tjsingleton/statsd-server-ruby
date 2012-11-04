module StatsD
  class Config < Struct.new(:host, :port, :graphite_host, :graphite_port, :flush_interval, :threshold_percentages)
    DEFAULT_HOST                  = 'localhost'
    DEFAULT_PORT                  = 8125
    DEFAULT_GRAPHITE_HOST         = 'localhost'
    DEFAULT_GRAPHITE_PORT         = 2003
    DEFAULT_FLUSH_INTERVAL        = 10.0
    DEFAULT_THRESHOLD_PERCENTAGES = [90.0]

    def self.from_hash(hash)
      config = new
      config.members.each do |key|
        key = key.to_s
        config.send "#{key}=", hash[key] if hash.has_key?(key)
      end
      config
    end

    def initialize
      yield(self) if block_given?
      self.host                  ||= DEFAULT_HOST
      self.port                  ||= DEFAULT_PORT
      self.graphite_host         ||= DEFAULT_GRAPHITE_HOST
      self.graphite_port         ||= DEFAULT_GRAPHITE_PORT
      self.flush_interval        ||= DEFAULT_FLUSH_INTERVAL
      self.threshold_percentages ||= DEFAULT_THRESHOLD_PERCENTAGES
    end

    def threshold_percentages=(value)
      super Array(value).map(&:to_f)
    end

    private :[]
    private :[]=
  end
end
