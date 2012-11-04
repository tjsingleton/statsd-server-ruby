require "bundler/setup"
require_relative "server"

module StatsD
  class CLI
    def initialize(args)
      @config = Config.new
    end

    def run
      server = StatsD::Server.new @config
      trap('INT') { EM.stop }
      EM.run { server.start }
    end
  end
end
