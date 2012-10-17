require "pp"
require "benchmark"
require_relative '../lib/statsd'

tests = [
  'test:123|g',
  'test:1232|g',
  'timer:1235|ms',
  'invalid',
  'countera:1234|c',
  'counterb:12234|c|@1.0',
  'counterc:1234|c|@1',
  'counterd:12234|c|@1.01',
  'countere:-12|c|@1.0',
  'gauge:1|g',
  'gauge.complex:1123|g'
]
joined_tests = tests.join("\n")

expected = [
  ["Gauge", "test", "123", nil],
  ["Gauge", "test", "1232", nil],
  ["Timer", "timer", "1235", nil],
  ["Counter", "countera", "1234", nil],
  ["Counter", "counterb", "12234", "1.0"],
  ["Counter", "counterc", "1234", "1"],
  ["Counter", "counterd", "12234", "1.01"],
  ["Counter", "countere", "-12", "1.0"],
  ["Gauge", "gauge", "1", nil],
  ["Gauge", "gauge.complex", "1123", nil]
]

N = 10_000
parser = StatsD::Parser.new
actual = parser.run(joined_tests)

puts
pp actual
puts
puts "Expected output? #{actual == expected}"
puts
puts "Parser: #{parser.class}, N: #{N}"

Benchmark.bmbm do |x|
  x.report("Single Line") { N.times { tests.each {|n| parser.run(n) } } }
  x.report("Multiple Lines") { N.times { parser.run(joined_tests)  } }
end
puts

