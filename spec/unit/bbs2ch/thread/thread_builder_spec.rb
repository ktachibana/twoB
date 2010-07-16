# -*- coding: utf-8 -*-
require 'twob/thread'
require 'bbs2ch/thread'
require 'io'

include BBS2ch

describe ThreadBuilder do
  before do
    @factory = mock(:factory)
    @factory.should_receive(:dat_builder).twice.and_return{ BBS2ch::DatBuilder.new }
    @factory.should_receive(:load_metadata).and_return{ YAML::load_file("testData/2ch/example(1-80).dat.metadata") }
    @factory.should_receive(:cache_source).and_return{ TextFile.by_filename("testData/2ch/example(1-80).dat", "windows-31j") }
    @key = mock(:key)
    @picker = mock(:picker)
    @builder = TwoB::ThreadBuilder.new(@factory, @key, @picker)
  end

  it "load_cache" do
    @builder.load_cache(1..1, 30..50)
    thread = @builder.result
    thread.last_res_number.should == 50
    res = thread.to_a
    res.count.should == 22
    thread[1].date.should == "2008/08/17(日) 15:30:19"
    thread[30].date.should == "2008/08/21(木) 22:39:34"
    thread[50].date.should == "2008/08/23(土) 15:11:47"
  end

  describe "delta" do
    before do
      @factory.should_receive(:delta_source_from).and_return{ BytesSource.new(File.read("testData/2ch/example(81-100).dat"), Encoder.by_name("windows-31j", "?"), "\n") }
    end

    it "load_delta" do
      @builder.load_delta
      thread = @builder.result
      thread.last_res_number.should == 100
      thread.to_a.count.should == 20
    end

    it "フィルタ付きload_delta" do
      @builder.load_delta do |res|
        (90..95).include?(res.number)
      end
      thread = @builder.result
      res = thread.to_a
      res.count.should == 6
      res.first.number.should == 90
      thread.last_res_number.should == 95
    end
  end
end
