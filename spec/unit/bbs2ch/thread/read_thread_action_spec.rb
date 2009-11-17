# -*- coding: utf-8 -*-
require 'spec_system'
require 'io/file'
require 'twob/request'
require 'bbs2ch/thread/thread'

describe "2chのスレッドを読む" do
  include BBS2ch

  before do
    @system = SpecSystem.new(TwoB::Request.new("/pc11.2ch.net/board/123/l50#firstNew", {}))
  end
  
  it "キャッシュなしの初読み込み" do
    SpecSystem.clear_cache_dir
    class BBS2ch::Thread
      def load_new_data(cache)
        BinaryFile.by_filename("testData/2ch/2ch_with_id_short.dat").read
      end
    end
    
    @system.process
    @system.response.status_code.should == 200
    html = @system.response.document
    html.title.should == "KDE スレッド7"
  end
  
  it "新着なしでキャッシュのみ" do
    class BBS2ch::Thread
      def load_new_data(cache)
        BinaryFile.by_filename("testData/2ch/2ch_with_id_short.dat").read
      end
    end
    SpecSystem.clear_cache_dir
    @system.process
    
    class BBS2ch::Thread
      def load_new_data(cache)
        ""
      end
    end
    @system = SpecSystem.new(TwoB::Request.new("/pc11.2ch.net/board/123/l50#firstNew", {}))
    @system.process
    
    response = @system.response
    response.status_code.should == 200
    html = response.document
    html.title.should == "KDE スレッド7"
    html.should_not be_has_new
  end
end
