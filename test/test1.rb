#!/bin/env ruby
#-*- coding: utf-8 -*-
require("test/unit");
require("../lib/optparshie");

class TestCase_Main < Test::Unit::TestCase
  def test_fundamental()
    argv = "--exp --wa -a 2 ADDITION".split(/\s+/);
    
    opt = OptionParshie.new();
    opt.on("-a","--a-value=VAL");
    opt.on("--exp");
    opt.on("-w","--waros");
    opt.on("-k");
    opt.parse(argv);
    
    assert_equal(opt.a, "2");
    assert_equal(opt.a_value, "2");
    assert(opt.exp);
    assert(opt.w);
    assert(opt.waros);
    assert(!opt.k);
  end
  
  def test_reference()
    argv = "--test=128 --example".split(/\s+/);
    
    opt = OptionParshie.new();
    opt.on("-t","--test=VAL",Integer);
    opt.on("-e","--example");
    opt.parse(argv);
    
    assert_equal(opt.t, 128);
    assert_equal(opt.test, 128);
    assert(opt.e);
    opt.t = 129;
    assert_equal(opt.t, 129);
    assert_equal(opt.test, 129);
    opt.e = "exp";
    assert_equal(opt.e, "exp");
    assert_equal(opt.example, "exp");
  end
end
