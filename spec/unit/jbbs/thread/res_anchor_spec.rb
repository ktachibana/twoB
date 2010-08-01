# -*- coding: utf-8 -*-
require 'spec_context'
require 'twob/request'
require 'twob/thread'
require 'twob/thread/picker'
require 'twob/thread/res_anchor_view'

describe "ResAnchor" do
  include TwoB::Spec

  before do
    @thread = root / "jbbs.livedoor.jp" / "cat" / "012" / "345"
  end

  it ">>50を参照する" do
    view = @thread.res_anchor(TwoB::Picker::Only.new(50))
    view.should be_kind_of(ResAnchorView)
    view.res_list.should be_kind_of(Array)
  end
end
