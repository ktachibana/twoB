# -*- coding: utf-8 -*-
require 'spec'
require 'jbbs/thread'

describe TwoB::Dat, "body parser" do
  include TwoB::Dat

  it 'parse' do
    body_str =
    'one' +
    '<a href="/bbs/read.cgi/1/2/3" target="_blank">&gt;&gt;3</a>' +
    '<br>' +
    'two' +
    '<a href="/bbs/read.cgi/1/2/4" target="_blank">&gt;&gt;4</a>' +
    '&gt;3 ' +
    '&gt;&gt;4-5' +
    'http://foo.bar/<br>' +
    'ttp://baz.com/aaaaa#abc&aa=bb'
    'three'
    dat_content = parse_body(body_str)
    dat_content.should_not be_nil
    dat_content.size.should == 11
  end
end
