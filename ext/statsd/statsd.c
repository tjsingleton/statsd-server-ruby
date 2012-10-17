#include "ruby.h"
#include "statsd_parser.h"

static VALUE mStatsd;
static VALUE cStatsdParser;

void emit_stat(void *stack, const char *type, const char *name_start, size_t name_length,
                                              const char *value_start, size_t value_length,
                                              const char *sample_rate_start, size_t sample_rate_length)
{
  VALUE stat_type = Qnil;
  VALUE name = Qnil;
  VALUE value = Qnil;
  VALUE sample_rate = Qnil;
  VALUE stat = rb_ary_new();

  stat_type = rb_str_new(type, strlen(type));

  if (name_length) { name = rb_str_new(name_start, name_length); }
  if (value_length) value = rb_str_new(value_start, value_length);
  if (sample_rate_length) sample_rate = rb_str_new(sample_rate_start, sample_rate_length);

  rb_ary_push((VALUE) stat, stat_type);
  rb_ary_push((VALUE) stat, name);
  rb_ary_push((VALUE) stat, value);
  rb_ary_push((VALUE) stat, sample_rate);
  rb_ary_push((VALUE) stack, stat);
}

VALUE StatsdParser_run(VALUE self, VALUE data)
{
  char *dptr = RSTRING_PTR(data);
  long dlen = RSTRING_LEN(data);
  char stat_str[dlen + 1];
  VALUE stack = rb_ary_new();
  statsd_parser parser;

  statsd_parser_init(&parser);
  parser.emit_stat = emit_stat;
  parser.stack = (void *) stack;

  // Ensure stat string is terminated with a \n
  sprintf(stat_str, "%s\n", dptr);

  statsd_parser_exec(&parser, stat_str, dlen + 1);

  return stack;
}

void Init_statsd()
{
  mStatsd = rb_define_module("StatsD");
  cStatsdParser = rb_define_class_under(mStatsd, "Parser", rb_cObject);
  rb_define_method(cStatsdParser, "run", StatsdParser_run, 1);
}
