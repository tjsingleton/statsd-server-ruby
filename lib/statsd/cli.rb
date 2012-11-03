require "ostruct"
require "bundler/setup"

require_relative "server"

module StatsD
  class CLI
    def initialize(args)
    end

    DEFAULT_GRAPHITE_HOST  = 'localhost'
    DEFAULT_GRAPHITE_PORT  = 2003
    DEFAULT_HOST           = 'localhost'
    DEFAULT_PORT           = 8125
    DEFAULT_FLUSH_INTERVAL = 10

    def run
      config = OpenStruct.new host: DEFAULT_HOST,
                              port: DEFAULT_PORT,
                              flush_interval: DEFAULT_FLUSH_INTERVAL,
                              graphite_host: DEFAULT_GRAPHITE_HOST,
                              graphite_port: DEFAULT_GRAPHITE_PORT

      server = StatsD::Server.new config
      trap('INT') { EM.stop }
      EM.run { server.start }
    end
  end
end
