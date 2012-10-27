# StatsD

A Ruby statsd server

## Each Flush

* statsd.numStats - the number of stats that were flushed to graphite
* stats.statsd.graphiteStats.calculationtime - the duration in ms that it took to calculate the stats for the flush

## Counters

* stats.#{key} - the count adjusted to count / per second
* stats_counts.#{key} - the count

# Gauges

* stats.gauges.#{key} - the value of the gauge

## Inspirations

* Etsy's statsd (https://github.com/etsy/statsd)
* Mongrel (https://github.com/evan/mongrel) as a pattern for some of the Ragel and C ext.
