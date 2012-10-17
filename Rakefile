require 'rake/extensiontask'

Rake::ExtensionTask.new('statsd')

file 'ext/statsd/statsd_parser.c' => ['ext/statsd/statsd_parser.c.rl'] do |t|
  begin
    sh "ragel #{t.prerequisites.last} -C -G2 -o #{t.name}"
  rescue
    fail "Could not build wrapper using Ragel (it failed or not installed?)"
  end
end

task ragel: 'ext/statsd/statsd_parser.c'
