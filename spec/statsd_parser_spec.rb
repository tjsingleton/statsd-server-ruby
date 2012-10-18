require_relative "../lib/statsd"

describe StatsD::Parser do
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

  subject { StatsD::Parser.new }
  let(:listener) { StatListener.new }

  def parsed_stack_should_eq(line, expected)
    subject.run(line, listener)
    listener.stack.should == expected
  end

  it "can parse a simple counter" do
    parsed_stack_should_eq 'test-count:1|c|@1.0', [[:counter, 'test-count', 1, 1.0]]
  end

  it "can parse a simple gauge" do
    parsed_stack_should_eq 'a.key:123|g', [[:gauge, 'a.key', 123]]
  end

  it "can parse a simple timer" do
    parsed_stack_should_eq 'timed.action:1000|ms', [[:timer, 'timed.action', 1000]]
  end

  it "defaults a counters sample rate to 1.0" do
    parsed_stack_should_eq 'test-count:1|c', [[:counter, 'test-count', 1, 1.0]]
  end

  it "handles multi-line input" do
    stat_str = [
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
    ].join("\n")

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

    parsed_stack_should_eq stat_str, expected
  end
end
