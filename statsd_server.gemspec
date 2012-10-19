Gem::Specification.new do |s|
  # required
  s.name        = 'statsd_server'
  s.version     = '0.0.1'
  s.date        = '2012-10-18'
  s.summary     = "A Statsd server in Ruby"
  s.files       = %w[]

  # optional
  s.license     = 'MIT'
  s.author      = "TJ Singleton"
  s.email       = 'tjsingleton@me.com'
  s.homepage    = 'https://github.com/tjsingleton/statsd-server-ruby'
  s.extensions << 'ext/statsd/extconf.rb'

  s.add_dependency('eventmachine')
  s.add_development_dependency "rake"
  s.add_development_dependency "rake-compiler"
  s.add_development_dependency "rspec", "~> 2.8.0"
end
