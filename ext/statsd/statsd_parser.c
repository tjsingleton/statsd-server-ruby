
#line 1 "ext/statsd/statsd_parser.c.rl"
#include "statsd_parser.h"

#define MARK(FPC) parser->mark = FPC - buffer
#define CAPTURE(LABEL, FPC) do { \
  parser->LABEL.start = buffer + parser->mark; \
  parser->LABEL.len = FPC - buffer - parser->mark; \
} while (0)
#define EMIT(T) ( statsd_parser_emit(parser, T) )

/** Machine **/

#line 23 "ext/statsd/statsd_parser.c.rl"



/** Private **/
void statsd_parser_clear_stat(statsd_parser *parser) {
  parser->name.start = NULL;
  parser->name.len = 0;

  parser->value.start = NULL;
  parser->value.len = 0;

  parser->sample_rate.start = NULL;
  parser->sample_rate.len = 0;
}

void statsd_parser_emit(statsd_parser *parser, const char *type) {
  parser->emit_stat(parser->stack, type, parser->name.start, parser->name.len,
                                         parser->value.start, parser->value.len,
                                         parser->sample_rate.start, parser->sample_rate.len);

  statsd_parser_clear_stat(parser);
}


/** Data **/

#line 42 "ext/statsd/statsd_parser.c"
static const int statsd_start = 13;
static const int statsd_first_final = 13;
static const int statsd_error = -1;

static const int statsd_en_main = 13;


#line 49 "ext/statsd/statsd_parser.c.rl"


/** Public **/
void statsd_parser_init(statsd_parser *parser) {
  int cs = 0;

  /* Init */
  
#line 59 "ext/statsd/statsd_parser.c"
	{
	cs = statsd_start;
	}

#line 57 "ext/statsd/statsd_parser.c.rl"

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
  
#line 81 "ext/statsd/statsd_parser.c"
	{
	if ( p == pe )
		goto _test_eof;
	switch ( cs )
	{
tr12:
#line 20 "ext/statsd/statsd_parser.c.rl"
	{ EMIT(Counter); }
	goto st13;
tr15:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
#line 17 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(sample_rate, p); }
#line 20 "ext/statsd/statsd_parser.c.rl"
	{ EMIT(Counter); }
	goto st13;
tr18:
#line 17 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(sample_rate, p); }
#line 20 "ext/statsd/statsd_parser.c.rl"
	{ EMIT(Counter); }
	goto st13;
tr21:
#line 18 "ext/statsd/statsd_parser.c.rl"
	{ EMIT(Gauge); }
	goto st13;
tr23:
#line 19 "ext/statsd/statsd_parser.c.rl"
	{ EMIT(Timer); }
	goto st13;
st13:
	if ( ++p == pe )
		goto _test_eof13;
case 13:
#line 117 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto tr25;
		case 58: goto tr26;
	}
	goto tr24;
tr24:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
	goto st0;
st0:
	if ( ++p == pe )
		goto _test_eof0;
case 0:
#line 131 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto st14;
		case 58: goto tr2;
	}
	goto st0;
tr25:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
	goto st14;
st14:
	if ( ++p == pe )
		goto _test_eof14;
case 14:
#line 145 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto tr25;
		case 58: goto tr27;
	}
	goto tr24;
tr2:
#line 15 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(name, p); }
	goto st1;
tr26:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
#line 15 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(name, p); }
	goto st1;
tr27:
#line 15 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(name, p); }
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
	goto st1;
st1:
	if ( ++p == pe )
		goto _test_eof1;
case 1:
#line 171 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto st13;
		case 45: goto tr5;
		case 124: goto tr6;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto tr5;
	goto st2;
st2:
	if ( ++p == pe )
		goto _test_eof2;
case 2:
	if ( (*p) == 10 )
		goto st13;
	goto st2;
tr5:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
	goto st3;
st3:
	if ( ++p == pe )
		goto _test_eof3;
case 3:
#line 195 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto st13;
		case 124: goto tr8;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st3;
	goto st2;
tr6:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
#line 16 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(value, p); }
	goto st4;
tr8:
#line 16 "ext/statsd/statsd_parser.c.rl"
	{ CAPTURE(value, p); }
	goto st4;
st4:
	if ( ++p == pe )
		goto _test_eof4;
case 4:
#line 217 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto st13;
		case 99: goto st5;
		case 103: goto st10;
		case 109: goto st11;
	}
	goto st2;
st5:
	if ( ++p == pe )
		goto _test_eof5;
case 5:
	switch( (*p) ) {
		case 10: goto tr12;
		case 124: goto st6;
	}
	goto st2;
st6:
	if ( ++p == pe )
		goto _test_eof6;
case 6:
	switch( (*p) ) {
		case 10: goto st13;
		case 64: goto st7;
	}
	goto st2;
st7:
	if ( ++p == pe )
		goto _test_eof7;
case 7:
	switch( (*p) ) {
		case 10: goto tr15;
		case 45: goto tr16;
		case 46: goto tr17;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto tr16;
	goto st2;
tr16:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
	goto st8;
st8:
	if ( ++p == pe )
		goto _test_eof8;
case 8:
#line 263 "ext/statsd/statsd_parser.c"
	switch( (*p) ) {
		case 10: goto tr18;
		case 46: goto st9;
	}
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st8;
	goto st2;
tr17:
#line 14 "ext/statsd/statsd_parser.c.rl"
	{ MARK(p); }
	goto st9;
st9:
	if ( ++p == pe )
		goto _test_eof9;
case 9:
#line 279 "ext/statsd/statsd_parser.c"
	if ( (*p) == 10 )
		goto tr18;
	if ( 48 <= (*p) && (*p) <= 57 )
		goto st9;
	goto st2;
st10:
	if ( ++p == pe )
		goto _test_eof10;
case 10:
	if ( (*p) == 10 )
		goto tr21;
	goto st2;
st11:
	if ( ++p == pe )
		goto _test_eof11;
case 11:
	switch( (*p) ) {
		case 10: goto st13;
		case 115: goto st12;
	}
	goto st2;
st12:
	if ( ++p == pe )
		goto _test_eof12;
case 12:
	if ( (*p) == 10 )
		goto tr23;
	goto st2;
	}
	_test_eof13: cs = 13; goto _test_eof; 
	_test_eof0: cs = 0; goto _test_eof; 
	_test_eof14: cs = 14; goto _test_eof; 
	_test_eof1: cs = 1; goto _test_eof; 
	_test_eof2: cs = 2; goto _test_eof; 
	_test_eof3: cs = 3; goto _test_eof; 
	_test_eof4: cs = 4; goto _test_eof; 
	_test_eof5: cs = 5; goto _test_eof; 
	_test_eof6: cs = 6; goto _test_eof; 
	_test_eof7: cs = 7; goto _test_eof; 
	_test_eof8: cs = 8; goto _test_eof; 
	_test_eof9: cs = 9; goto _test_eof; 
	_test_eof10: cs = 10; goto _test_eof; 
	_test_eof11: cs = 11; goto _test_eof; 
	_test_eof12: cs = 12; goto _test_eof; 

	_test_eof: {}
	}

#line 73 "ext/statsd/statsd_parser.c.rl"
}
