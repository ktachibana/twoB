# -*- coding: utf-8 -*-
require 'twob/thread'

include TwoB

describe TwoB::Thread do
  it "スレタイはdatの>>1に含まれる"
  it ">>1が表示範囲外でもmetadataからスレタイを取得できる"
end
