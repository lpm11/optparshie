#!/bin/env ruby
#-*- coding: utf-8 -*-
require("rubygems");
require("optparse");

class OptionParshie < OptionParser
  def initialize()
    super;
    @hash = {};
  end

  def hash_key_sanitize(switch)
    return switch.gsub(/^-+/,"").gsub(/\W/,"_");
  end

  def hash_sw_add(sw,val)
    (sw.short+sw.long).each { |switch| @hash[hash_key_sanitize(switch)] = val; }
  end

  def parse(*argv)
    @hash = {};
    top.list.each { |sw| hash_sw_add(sw,nil); }
    super;
  end
  
  def parse!(*argv)
    @hash = {};
    top.list.each { |sw| hash_sw_add(sw,nil); }
    super;
  end

  # ----------------------------------------------------------------------------
  # Borrowed from optparse.rb
  #   (author of optparse.rb is Nobu Nakada-san, thank you!)
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
            hash_sw_add(sw,val);
            
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
            hash_sw_add(sw,val);
            
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
    if (@hash.key?(name))
      return @hash[name];
    else
      super;
    end
  end

  attr_reader :hash;
  private :hash_key_sanitize, :hash_sw_add;
end
