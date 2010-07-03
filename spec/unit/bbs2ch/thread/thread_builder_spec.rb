# -*- coding: utf-8 -*-
require 'twob/thread'
require 'bbs2ch/thread'
require 'io'

include BBS2ch

describe ThreadBuilder do
  before do
    @factory = mock(:factory)
    @factory.should_receive(:dat_builder).twice.and_return{ BBS2ch::DatBuilder.new }
    @factory.should_receive(:load_index).and_return(YAML::load_file("testData/2ch/example(1-80).dat.index"))
    @factory.should_receive(:cache_source).and_return{ TextFile.by_filename("testData/2ch/example(1-80).dat", "windows-31j") }
    @factory.should_receive(:delta_source_from).and_return{ BytesSource.new(File.read("testData/2ch/example(81-100).dat"), Encoder.by_name("windows-31j", "?"), "\n") }
    @key = mock(:key)
    @picker = mock(:picker)
    @builder = BBS2ch::ThreadBuilder.new(@factory, @key, @picker)
  end

  it "load_cache" do
    @builder.load_cache(1..1, 30..50)
    thread = @builder.result
    thread.last_res_number.should == 50
  end

  describe "delta" do
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
