# -*- coding: utf-8 -*-

module TwoB
  # includeするクラスは以下のメソッドを提供すること
  # * get_child(value:String) => Handler valueに対応する子ハンドラ
  # * execute(value) valueに対応するアクションを実行する
  module Handler
    def apply(request, path_info)
      if index = path_info.index("/")
        value = path_info[0...index]
        rest = path_info[(index+1)..-1]
        get_child(value).apply(request, rest)
      else
        execute(request, path_info)
      end
    end
    
    def /(value)
      get_child(value)
    end
  end
end
