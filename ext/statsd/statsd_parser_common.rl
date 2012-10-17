%%{
  machine statsd_parser_common;

  name         = (any - ':')*                           >Mark %Name;
  value        = (('-')? digit*)                        >Mark %Value;
  sample_rate  = (('-')? (digit* | digit* '.' digit*))  >Mark %SampleRate;
  kv_pair      = name ':' value;

  gauge        = kv_pair '|g'                         %Gauge;
  timer        = kv_pair '|ms'                        %Timer;
  counter      = kv_pair ('|c' | '|c|@' sample_rate)  %Counter;

  stat         = (gauge | timer | counter);

  main := ((stat | !stat) '\n')*;
}%%
