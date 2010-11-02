# -*- coding: utf-8 -*-

module TwoB
  # includeするクラスはTwoB::BoardHandlerをincludeすること
  module ReadCounter
    def update(thread_number, read_count)
      metadata_manager.update do |board_metadata|
        board_metadata[thread_number] = read_count
      end
    end

    def delete(thread_number)
      metadata_manager.update do |board_metadata|
        board_metadata.delete(thread_number)
      end
    end
  end
end