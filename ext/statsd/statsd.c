#include "ruby.h"
#include "statsd_parser.h"

static VALUE mStatsd;
static VALUE cStatsdParser;

static ID id_visit_Counter;
static ID id_visit_Gauge;
static ID id_visit_Timer;
static ID id_to_i;
static ID id_to_f;

void emit_stat(void *stack, stat_type type, const char *name_start, size_t name_length,
                                            const char *value_start, size_t value_length,
                                            const char *sample_rate_start, size_t sample_rate_length)
{
  VALUE name = Qnil;
  VALUE value = Qnil;
  VALUE sample_rate;

  if (name_length) { name = rb_str_new(name_start, name_length); }

  if (value_length) {
    value = rb_str_new(value_start, value_length);
    value = rb_funcall(value, id_to_i, 0);
  }

  switch(type) {
  case COUNTER:
    if (sample_rate_length) {
      sample_rate = rb_str_new(sample_rate_start, sample_rate_length);
      sample_rate = rb_funcall(sample_rate, id_to_f, 0);
    } else {
      sample_rate = rb_float_new(1.0);
    }

    if (value == Qnil) { value = FIX2INT(1); }

    rb_funcall((VALUE) stack, id_visit_Counter, 3, name, value, sample_rate);
    break;

  case GAUGE:
    rb_funcall((VALUE) stack, id_visit_Gauge, 2, name, value);
    break;

  case TIMER:
    rb_funcall((VALUE) stack, id_visit_Timer, 2, name, value);
    break;

  default:
    break;
  }
}

 /*
 * Document-method: StatsD::Parser#initialize
 * @overload initialize(visitor)
 * @param [StoreParsedStats] visitor
 */
VALUE StatsdParser_init(VALUE self, VALUE visitor)
{
  rb_iv_set(self, "@visitor", visitor);
  return self;
}

/*
 * Document-method: StatsD::Parser#call
 * @overload call(message)
 * @param [String] message
 */
VALUE StatsdParser_call(VALUE self, VALUE data)
{
  char *dptr = RSTRING_PTR(data);
  long dlen = RSTRING_LEN(data);
  char stat_str[dlen + 1];
  VALUE stack = rb_ary_new();
  VALUE visitor = rb_iv_get(self, "@visitor");
  statsd_parser parser;

  statsd_parser_init(&parser);
  parser.emit_stat = emit_stat;
  parser.data = (void *) visitor;

  // Ensure stat string is terminated with a \n
  sprintf(stat_str, "%s\n", dptr);

  statsd_parser_exec(&parser, stat_str, dlen + 1);

  return stack;
}

/* Document-class: StatsD::Parser
 * Translates a StatsD Protocol message into messages sent to it's visitor.
 *
 * @example Print out the parsed message
 *   class VisitMessagePrinter
 *     def method_missing(method_sym, *arguments, &block)
 *       if method_sym.to_s =~ /^visit_(.*)$/
 *         puts [" *", $1, *arguments].join(" ")
 *       else
 *         super
 *       end
 *     end
 *   end
 *
 *   parser = StatsD::Parser.new(VisitMessagePrinter.new)
 *   parser.call("timer:1000|ms\ncounter:1|c\ngauge:10|g\n")
 *
 *   # Output:
 *   # * Timer timer 1000
 *   # * Counter counter 1 1.0
 *   # * Gauge gauge 10
 */
void Init_statsd()
{
  mStatsd = rb_define_module("StatsD");
  cStatsdParser = rb_define_class_under(mStatsd, "Parser", rb_cObject);
  rb_define_method(cStatsdParser, "initialize", StatsdParser_init, 1);
  rb_define_method(cStatsdParser, "call", StatsdParser_call, 1);


  id_visit_Counter = rb_intern("visit_Counter");
  id_visit_Gauge   = rb_intern("visit_Gauge");
  id_visit_Timer   = rb_intern("visit_Timer");

  id_to_i = rb_intern("to_i");
  id_to_f = rb_intern("to_f");
}
