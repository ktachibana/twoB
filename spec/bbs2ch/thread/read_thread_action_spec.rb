# -*- coding: utf-8 -*-
require 'spec_system'
require 'io/file'
require 'twob/request'
require 'bbs2ch/thread/thread'
require 'hpricot'
require 'pp'

describe "2chのスレッドを読む" do
  include BBS2ch
  
  before do
    @system = SpecSystem.new(TwoB::Request.new("/pc11.2ch.net/board/123/l50#firstNew", {}))
  end
  
  it "例" do
    class BBS2ch::Thread
      def load_new_data(cache)
        BinaryFile.by_filename("testData/2ch/2ch_with_id_short.dat").read
      end
    end
    
    @system.process
    @system.response.status_code.should == 200
    html = Hpricot(@system.response_body)
    html.search("title").text.should == "KDE スレッド7"
  end
  
  it "新着なしでキャッシュのみ" do
    class BBS2ch::Thread
      def load_new_data(cache)
        BinaryFile.by_filename("testData/2ch/2ch_with_id_short.dat").read
      end
    end
    @system.configuration.data_directory.rmtree
    @system.process
    
    class BBS2ch::Thread
      def load_new_data(cache)
        ""
      end
    end
    @system = SpecSystem.new(TwoB::Request.new("/pc11.2ch.net/board/123/l50#firstNew", {}))
    @system.process
    @system.response.status_code.should == 200
    
    html = Hpricot(@system.response_body)
    html.search("title").text.should == "KDE スレッド7"
    html.search("div.res dl.new").should be_empty
  end
end
