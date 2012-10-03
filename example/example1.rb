#!/bin/env ruby
#-*- coding: utf-8 -*-
require("../lib/optparshie");

argv = "--exp --wa -a 2 --on --no-foo --bar ADDITION".split(/\s+/);
puts("test argv: #{argv}");

opt = OptionParshie.new();
opt.on("-a","--a-value=VAL");
opt.on("--exp");
opt.on("-w","--waros");
opt.on("-o","--on");
opt.on("--[no-]foo");
opt.on("--[no-]bar");

# parse returns mash
puts("opt.parse => #{opt.parse(argv)}");
# parse! returns [argv, mash]
puts("opt.parse! => #{opt.parse!(argv)}");

# access with short option
puts("opt.a => #{opt.a}");
puts("opt.w => #{opt.w}");
puts("opt.o => #{opt.o}");

# access with long option
puts("opt.a_value => #{opt.a_value}");
puts("opt.exp => #{opt.exp}");
puts("opt.waros => #{opt.waros}");
# Oops! It's already defined method....
# opt.on => Usage: example1 (blah blah blah)

# You should access via short option instead.... :X
puts("opt.o => #{opt.o}");

# -no options
puts("opt.foo => #{opt.foo}");
puts("opt.bar => #{opt.bar}");
