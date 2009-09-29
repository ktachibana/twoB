require 'equality'
require 'test/unit'

include Test::Unit

class EqualityTest < TestCase
  class Book
    def initialize(title, index_no)
      @title = title
      @index_no = index_no
    end
    equality :@title, :@index_no
  end

  class SameInstanceVar # ex: Movie
    def initialize(title, index_no)
      @title = title
      @index_no = index_no
    end
    equality :@title, :@index_no
  end

  def setup
    @a_book = Book.new("I, Robot", 1)
    @same_book = Book.new("I, Robot", 1)
    @not_same_book = Book.new("Door into the Summer", 2)
    @partial_diff_book = Book.new("I, Robot", 3)
    @not_same_class = SameInstanceVar.new("I, Robot", 1)
  end


  def test_same_object
    assert_equal(@same_book, @a_book)
    assert_not_same(@same_book, @a_book)
  end
  
  def test_not_same_object
    assert_not_equal(@not_same_book, @a_book)
  end

  def test_partial_difference_object
    assert_not_equal(@partial_diff_book, @a_book)
  end
  
  def test_not_same_class
    assert_not_equal(@not_same_class, @a_book)
  end


  class NoEqualityBook
    def initialize(title, index_no)
      @title = title
      @index_no = index_no
    end
  end

  def test_no_equality_object_use_reference
    no_equality_book = NoEqualityBook.new("I, Robot", 1)
    no_equality_book2 = no_equality_book

    assert_not_equal(no_equality_book, @a_book)
    assert_equal(no_equality_book2, no_equality_book)
  end
end
