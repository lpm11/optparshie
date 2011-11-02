#!/bin/env ruby
#-*- coding: utf-8 -*-
require("../lib/optparshie");

argv = "--test --wa -a 2 --on".split(/\s+/);
puts("test argv: #{argv}");

opt = OptionParshie.new();
opt.on("-a","--a-value=VAL");
opt.on("--test");
opt.on("-w","--waros");
opt.on("-o","--on");
opt.parse(argv);

# access with short option
puts("opt.a => #{opt.a}");
puts("opt.w => #{opt.w}");
puts("opt.o => #{opt.o}");

# access with long option
puts("opt.a_value => #{opt.a_value}");
puts("opt.test => #{opt.test}");
puts("opt.waros => #{opt.waros}");
# Oops! This is already defined method....
# opt.on => Usage: example1 (blah blah blah)

# instead of you can access through hash
puts("opt.hash['on'] => #{opt.hash['on']}");
