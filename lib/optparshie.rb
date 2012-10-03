#!/bin/env ruby
#-*- coding: utf-8 -*-
require("rubygems");
require("optparse");

class OptionParshie < OptionParser
  def initialize()
    super;
    hash_init();
  end

  def hash_init()
    @opt_hash = Hash.new();
    @opt_key = Hash.new();
  end

  def hash_key_sanitize(switch)
    switch = switch.dup();
    switch.gsub!(/^--\[no-\]/,"--");
    switch.gsub!(/^-+/,"")
    switch.gsub!(/\W/,"_");
    
    return switch;
  end

  def hash_sw_add(sw,val)
    keys = (sw.short + sw.long).map { |x| hash_key_sanitize(x); };
    primary_key = keys.first;
    keys.each { |key| @opt_key[key] = primary_key; }
    
    @opt_hash[primary_key] = val;
  end

  def parse(*argv)
    hash_init();
    top.list.each { |sw| hash_sw_add(sw,nil); }
    x = super;
    
    return x;
  end
  
  def parse!(*argv)
    hash_init();
    top.list.each { |sw| hash_sw_add(sw,nil); }
    x = super;
    
    return x;
  end

  # ----------------------------------------------------------------------------
  # Borrowed from optparse.rb
  #   (author of optparse.rb is Nobu Nakada-san, thanks!)
  # ----------------------------------------------------------------------------
  def parse_in_order(argv = default_argv, setter = nil, &nonopt)  # :nodoc:
    opt, arg, val, rest = nil
    nonopt ||= proc {|a| throw :terminate, a}
    argv.unshift(arg) if arg = catch(:terminate) {
      while arg = argv.shift
        case arg
        # long option
        when /\A--([^=]*)(?:=(.*))?/m
          opt, rest = $1, $2
          begin
            sw, = complete(:long, opt, true)
          rescue ParseError
            raise $!.set_option(arg, true)
          end
          begin
            opt, cb, val = sw.parse(rest, argv) {|*exc| raise(*exc)}
            
            # ------------------------------------------------------------------
            # optparshie code by l.p.m.11
            # ------------------------------------------------------------------
            hash_sw_add(sw, val);
            
            val = cb.call(val) if cb
            setter.call(sw.switch_name, val) if setter
          rescue ParseError
            raise $!.set_option(arg, rest)
          end

        # short option
        when /\A-(.)((=).*|.+)?/m
          opt, has_arg, eq, val, rest = $1, $3, $3, $2, $2
          begin
            sw, = search(:short, opt)
            unless sw
              begin
                sw, = complete(:short, opt)
                # short option matched.
                val = arg.sub(/\A-/, '')
                has_arg = true
              rescue InvalidOption
                # if no short options match, try completion with long
                # options.
                sw, = complete(:long, opt)
                eq ||= !rest
              end
            end
          rescue ParseError
            raise $!.set_option(arg, true)
          end
          begin
            opt, cb, val = sw.parse(val, argv) {|*exc| raise(*exc) if eq}
            raise InvalidOption, arg if has_arg and !eq and arg == "-#{opt}"

            # ------------------------------------------------------------------
            # optparshie code by l.p.m.11
            # ------------------------------------------------------------------
            hash_sw_add(sw, val);
            
            argv.unshift(opt) if opt and (!rest or (opt = opt.sub(/\A-*/, '-')) != '-')
            val = cb.call(val) if cb
            setter.call(sw.switch_name, val) if setter
          rescue ParseError
            raise $!.set_option(arg, arg.length > 2)
          end

        # non-option argument
        else
          catch(:prune) do
            visit(:each_option) do |sw0|
              sw = sw0
              sw.block.call(arg) if Switch === sw and sw.match_nonswitch?(arg)
            end
            nonopt.call(arg)
          end
        end
      end

      nil
    }

    visit(:search, :short, nil) {|sw| sw.block.call(*argv) if !sw.pattern}

    argv
  end

  def method_missing(name,*args)
    name = name.to_s();
    subst = !(name.gsub!(/=$/,"").nil?);
    raise if (!@opt_key.key?(name));

    if (!subst)
      return @opt_hash[@opt_key[name]];
    else
      return @opt_hash[@opt_key[name]] = args.first;
    end
  end

  attr_reader :opt_hash;
  private :hash_key_sanitize, :hash_sw_add, :hash_init;
end
