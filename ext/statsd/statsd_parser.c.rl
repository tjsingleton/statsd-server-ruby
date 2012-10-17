#include "statsd_parser.h"

#define MARK(FPC) parser->mark = FPC - buffer
#define CAPTURE(LABEL, FPC) do { \
  parser->LABEL.start = buffer + parser->mark; \
  parser->LABEL.len = FPC - buffer - parser->mark; \
} while (0)
#define EMIT(T) ( statsd_parser_emit(parser, T) )

/** Machine **/
%%{
  machine statsd;

  action Mark           { MARK(fpc); }
  action Name           { CAPTURE(name, fpc); }
  action Value          { CAPTURE(value, fpc); }
  action SampleRate     { CAPTURE(sample_rate, fpc); }
  action Gauge          { EMIT(GAUGE); }
  action Timer          { EMIT(TIMER); }
  action Counter        { EMIT(COUNTER); }

  include statsd_parser_common "statsd_parser_common.rl";
}%%


/** Private **/
void statsd_parser_clear_stat(statsd_parser *parser) {
  parser->name.start = NULL;
  parser->name.len = 0;

  parser->value.start = NULL;
  parser->value.len = 0;

  parser->sample_rate.start = NULL;
  parser->sample_rate.len = 0;
}

void statsd_parser_emit(statsd_parser *parser, stat_type type) {
  parser->emit_stat(parser->data, type, parser->name.start, parser->name.len,
                                        parser->value.start, parser->value.len,
                                        parser->sample_rate.start, parser->sample_rate.len);

  statsd_parser_clear_stat(parser);
}


/** Data **/
%% write data;


/** Public **/
void statsd_parser_init(statsd_parser *parser) {
  int cs = 0;

  /* Init */
  %% write init;

  parser->cs = cs;
  parser->mark = 0;

  statsd_parser_clear_stat(parser);
}

void statsd_parser_exec(statsd_parser *parser, const char *buffer, size_t len) {
  const char *p, *pe;
  int cs = parser->cs;

  p = buffer;
  pe = buffer+len;

  /* Exec */
  %% write exec;
}
