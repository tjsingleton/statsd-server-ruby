# StatsD

A Ruby statsd server [![Build Status](https://secure.travis-ci.org/tjsingleton/statsd-server-ruby.png)](http://travis-ci.org/tjsingleton/statsd-server-ruby)

## Each Flush

* statsd.numStats - the number of stats that were flushed to graphite
* stats.statsd.graphiteStats.calculationtime - the duration in ms that it took to calculate the stats for the flush

## Counters

* stats.KEY - the count adjusted to count / per second
* stats_counts.KEY - the count

## Gauges

* stats.gauges.KEY - the value of the gauge

## Timers

* stats.timers.KEY.count - number of timings
* stats.timers.KEY.lower - minimum timing
* stats.timers.KEY.mean - average
* stats.timers.KEY.std - standard deviation
* stats.timers.KEY.sum - sum of timings
* stats.timers.KEY.upper - maximum timing

The default percentile is 90. You can provide a list of percentiles to calculate. For each percentile we calculate:

* stats.timers.KEY.mean_PERCENT - the mean of that percentile
* stats.timers.KEY.sum_PERCENT - the sum of that percentile
* stats.timers.KEY.upper_PERCENT - the max of that percentile

## Inspirations

* Etsy's statsd (https://github.com/etsy/statsd)
* Mongrel (https://github.com/evan/mongrel) as a pattern for some of the Ragel and C ext.
