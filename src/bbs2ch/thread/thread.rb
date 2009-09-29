require 'twob/thread_handler'
require 'twob/marshaler'
require 'bbs2ch/thread/dat_parser'
require 'bbs2ch/thread/res'
require 'bbs2ch/thread/cache'
require 'bbs2ch/thread/cache_manager'
require 'thread_view'
require 'source'
require 'time'

module BBS2ch
  class Thread
    def initialize(board, number)
      @board = board
      @number = number
    end
    
    attr_reader :board, :number
    
    
    include TwoB::Handler
    
    def get_child(value)
      BBS2ch::Res.new(self, value.to_i)
    end
    
    
    include TwoB::ThreadHandler
    
    def read(requested_range)
      # キャッシュをロードしてDatContent, last_modified, cache_file_sizeを取得
      cache = cache_manager.load()
      # キャッシュ情報から新しく取得すべきコンテンツのリクエスト(Net::HTTP::Get.new(get_dat_url))を生成する
      new_data = load_new_data(cache)
      dat_parser = BBS2ch::DatParser.new(cache.new_number)
      new_dat_content = dat_parser.parse(BytesSource.new(new_data, dat_encoding, "\n"))
      option = option_manager.load()
      thread_content = TwoB::Thread.new(self, cache, new_dat_content, requested_range, option)

      cache_manager.append(new_data)
      read_counter.update(number, thread_content.res_count)
      
      ::ThreadView.new(thread_content)
    end
    
    def cache_manager
      BBS2ch::CacheManager.new(cache_source, get_dat_parser(), Cache::Empty)
    end
    
    def index_manager
      TwoB::Marshaler.new(index_file, JBBS::Index.Empty)
    end
    
    def load_new(cache)
      source = HTTPGetSource.new(dat_host_name, dat_path, dat_header(cache), dat_encoding, "\n")
      parser = BBS2ch::DatParser.new(cache.dat_content.last_res_number + 1)
      parser.parse(source)
    end
    
    def load_new_data(cache)
      HTTPGetInput.new(board.host.name, dat_path, cache.dat_header).read()
    end

    def original_url
      "http://#{board.host.name}/test/read.cgi/#{board.id}/#{number}/"
    end
    
    def data_directory_path
      board.data_directory_path
    end
    
    def dat_url
      "http://#{dat_host_name}#{dat_path}"
    end
    
    def dat_host_name
      board.host.name
    end
    
    def dat_path
      "/#{board.id}/dat/#{number}.dat"
    end
    
    def get_dat_url(from)
      dat_url
    end
    
    def cache_source
      TextFile.new(cache_file, dat_encoding.name)
    end
    
    def dat_encoding
      Encoder.by_name("MS932")
    end
    
    def get_dat_parser()
      BBS2ch::DatParser.new()
    end
    
    def system
      board.host.system
    end
        
    def read_counter
      board
    end
  end
end