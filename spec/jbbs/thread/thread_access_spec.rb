# -*- coding: utf-8 -*-
require 'spec_system'
require 'twob/request'
require 'io/file'
require 'nokogiri'

describe "JBBSのスレッドを読む" do
  include JBBS
  
  
  it "キャッシュなしの初回読み込み" do
    SpecSystem.clear_cache_dir
    class ThreadService
      def get_new_input(picker)
        BinaryFile.by_filename("testData/jbbs/example-1.dat")
      end
    end

    system = SpecSystem.new(TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/l50#firstNew", {}))
    system.process

    response = system.response
    response.status_code.should == 200
    response.content_type.should == "text/html; charset=UTF-8"
    
    thread = response.document
    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should be_exist
    thread[216].should be_new
    thread[217].should_not be_new
    created_cache = SpecSystem::SpecConfiguration.data_directory + "jbbs.livedoor.jp" + "category" + "123" + "456.dat"
    created_cache.size.should == 31178
  end
  
  it "追加読み込み" do
    class ThreadService
      def get_new_input(picker)
        BinaryFile.by_filename("testData/jbbs/example-2.dat")
      end
    end

    system = SpecSystem.new(TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/l50#firstNew", {}))
    system.process
    response = system.response

    response.status_code.should == 200
    
    thread = response.document

    thread.title.should == "鶉の羽の下（管理運営・意見・要望など）の7.5"
    thread[1].should be_new
    thread[217].should_not be_exist
  end
end
