require "yaml"
require "bundler/setup"
require_relative "server"

module StatsD
  class CLI
    DEFAULT_CONFIG_PATH = "/etc/statsd/config.yml"

    def initialize(args)
      config_path = DEFAULT_CONFIG_PATH

      OptionParser.new do |opts|
        opts.version = StatsD::VERSION
        opts.on("-cCONFIG",
                "--config CONFIG",
                "Configuration file path (default #{DEFAULT_CONFIG_PATH})"
        ) {|value| config_path = value }
      end.parse!(args)


      if File.exist?(config_path)
        parsed_config = YAML.load_file(config_path)
        @config       = Config.from_hash(parsed_config)
      else
        @config ||= Config.new
      end
    end

    def run
      server = StatsD::Server.new @config
      trap('INT') { EM.stop }
      EM.run { server.start }
    end
  end
end
