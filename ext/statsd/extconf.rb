require 'mkmf'

dir_config("statsd")
have_library("c", "main")

create_makefile("statsd")
