require 'rake/extensiontask'
require 'rspec/core/rake_task'

Rake::ExtensionTask.new('statsd')
RSpec::Core::RakeTask.new(:spec)

task default: :spec

file 'ext/statsd/statsd_parser.c' => ['ext/statsd/statsd_parser.c.rl'] do |t|
  begin
    sh "ragel #{t.prerequisites.last} -C -G2 -o #{t.name}"
  rescue
    fail "Could not build wrapper using Ragel (it failed or not installed?)"
  end
end

task ragel: 'ext/statsd/statsd_parser.c'

