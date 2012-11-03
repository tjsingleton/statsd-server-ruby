# StatsD

A Ruby statsd server [![Build Status](https://secure.travis-ci.org/tjsingleton/statsd-server-ruby.png)](http://travis-ci.org/tjsingleton/statsd-server-ruby)

## Each Flush

* statsd.numStats - the number of stats that were flushed to graphite
* stats.statsd.graphiteStats.calculationtime - the duration in ms that it took to calculate the stats for the flush

## Counters

* stats.#{key} - the count adjusted to count / per second
* stats_counts.#{key} - the count

## Gauges

* stats.gauges.#{key} - the value of the gauge

## Timers

* stats.timers.#{key}.count - number of timings
* stats.timers.#{key}.lower - minimum timing
* stats.timers.#{key}.mean - average
* stats.timers.#{key}.std - standard deviation
* stats.timers.#{key}.sum - sum of timings
* stats.timers.#{key}.upper - maximum timing

The default percentile is 90. You can provide a list of percentiles to calculate. For each percentile we calculate:

* stats.timers.#{key}.mean_#{percent} - the mean of that percentile
* stats.timers.#{key}.sum_#{percent} - the sum of that percentile
* stats.timers.#{key}.upper_#{percent} - the max of that percentile

## Inspirations

* Etsy's statsd (https://github.com/etsy/statsd)
* Mongrel (https://github.com/evan/mongrel) as a pattern for some of the Ragel and C ext.
