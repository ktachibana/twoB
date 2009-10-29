# -*- coding: utf-8 -*-

module TwoB
  # includeするクラスはTwoB::BoardHandlerをincludeすること
  module ReadCounter
    def update(thread_number, read_count)
      index_manager.update do |board_index|
        board_index[thread_number] = read_count
      end
    end
    
    def delete(thread_number)
      index_manager.update do |board_index|
        board_index.delete(thread_number)
      end
    end
  end
end