require_relative "../lib/statsd/config"

describe StatsD::Config do
  it "yields self on initialize" do
    yielded = nil
    config = StatsD::Config.new {|n| yielded = n }
    yielded.should == config
  end

  it "casts threshold percentages to an array of floats" do
    config = StatsD::Config.new

    config.threshold_percentages = 90
    config.threshold_percentages.should == [90.0]
  end

  it "hides the subscript operator" do
    config = StatsD::Config.new

    config.should_not respond_to(:[])
    config.should_not respond_to(:[]=)
  end

  it "sets the default values" do
    config = StatsD::Config.new
    config.port.should == StatsD::Config::DEFAULT_PORT
  end

  it "doesn't overwrite a set value" do
    config = StatsD::Config.new {|n| n.port = 1 }
    config.port.should == 1
  end
end
