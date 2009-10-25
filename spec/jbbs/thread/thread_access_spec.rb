# -*- coding: utf-8 -*-
require 'spec_system'
require 'io/file'
require 'twob/request'
require 'jbbs/thread/thread_service'

describe "JBBSのスレッドを読む" do
  include JBBS
  
  it "例" do
    class ThreadService
      def get_new_input(picker)
        BinaryFile.by_filename("testData/jbbs/jbbs.dat")
      end
    end

    twob = SpecSystem.new(TwoB::Request.new("/jbbs.livedoor.jp/category/123/456/l50#firstNew", {}))
    twob.process
    twob.response.status_code.should == 200
  end
end
