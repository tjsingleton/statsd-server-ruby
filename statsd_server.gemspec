require './lib/statsd/version'

Gem::Specification.new do |s|
  # required
  s.name        = 'statsd_server'
  s.version     = StatsD::VERSION
  s.date        = '2012-10-18'
  s.summary     = 'A Statsd server in Ruby'
  s.files       = `git ls-files`.split

  # optional
  s.description = <<-EOF
    Clone of etsy's statsd implemented in Ruby. It should be message compatible w\ the node version.
  EOF
  s.license     = 'MIT'
  s.author      = 'TJ Singleton'
  s.email       = 'tjsingleton@me.com'
  s.homepage    = 'https://github.com/tjsingleton/statsd-server-ruby'
  s.extensions << 'ext/statsd/extconf.rb'
  s.executables << 'statsd'


  s.add_dependency 'eventmachine'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'rspec'
end
