all: src/res_anchor_view.rb src/board_view.rb src/thread_view.rb erb2view.rb

src/res_anchor_view.rb: view/res_anchor.erb erb2view.rb
	./erb2view.rb view/res_anchor.erb > src/res_anchor_view.rb

src/board_view.rb: view/board.erb erb2view.rb
	./erb2view.rb view/board.erb > src/board_view.rb

src/thread_view.rb: view/thread.erb erb2view.rb
	./erb2view.rb view/thread.erb > src/thread_view.rb
