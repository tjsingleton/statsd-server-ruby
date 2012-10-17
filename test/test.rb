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
  [:gauge, "test", 123],
  [:gauge, "test", 1232],
  [:timer, "timer", 1235],
  [:counter, "countera", 1234, 1.0],
  [:counter, "counterb", 12234, 1.0],
  [:counter, "counterc", 1234, 1.0],
  [:counter, "counterd", 12234, 1.01],
  [:counter, "countere", -12, 1.0],
  [:gauge, "gauge", 1],
  [:gauge, "gauge.complex", 1123]
]

class StatListener
  attr_reader :stack

  def initialize
    @stack = []
  end

  def visit_Gauge(name, value)
    @stack.push [:gauge, name, value]
  end

  def visit_Timer(name, value)
    @stack.push [:timer, name, value]
  end

  def visit_Counter(name, value, sample_rate)
    @stack.push [:counter, name, value, sample_rate]
  end
end


listener = StatListener.new
parser   = StatsD::Parser.new
actual   = listener.stack

parser.run(joined_tests, listener)

N = 10_000

puts
pp actual
puts
puts "Expected output? #{actual == expected}"
puts
puts "Parser: #{parser.class}, N: #{N}"

Benchmark.bmbm do |x|
  x.report("Single Line") { N.times { tests.each {|n| parser.run(n, StatListener.new) } } }
  x.report("Multiple Lines") { N.times { parser.run(joined_tests, StatListener.new)  } }
end
puts

