#ifndef statsd_parser_h
#define statsd_parser_h

#include <sys/types.h>
#include <stdio.h>
#include <string.h>

static const char* Gauge   = "Gauge";
static const char* Counter = "Counter";
static const char* Timer   = "Timer";

typedef void (*stat_cb)(void *stack, const char *type, const char *name_start, size_t name_length,
                                     const char *value_start, size_t value_length,
                                     const char *sample_rate_start, size_t sample_rate_length);

typedef struct statsd_part {
  const char *start;
  size_t len;
} statsd_part;

typedef struct statsd_parser {
  int cs;
  size_t mark;

  void *stack;

  statsd_part name;
  statsd_part value;
  statsd_part sample_rate;

  stat_cb emit_stat;
} statsd_parser;

void statsd_parser_init(statsd_parser *parser);
void statsd_parser_exec(statsd_parser *parser, const char *buffer, size_t len);

#endif
