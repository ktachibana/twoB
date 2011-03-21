# -*- coding: utf-8 -*-
require 'util'

describe "Equality" do
  class Book
    def initialize(title, index_no)
      @title = title
      @index_no = index_no
    end
    equality :@title, :@index_no
  end

  class Movie
    def initialize(title, index_no)
      @title = title
      @index_no = index_no
    end
    equality :@title, :@index_no
  end

  before do
    @a_book = Book.new("I, Robot", 1)
    @same_book = Book.new("I, Robot", 1)
    @not_same_book = Book.new("Door into the Summer", 2)
    @partial_diff_book = Book.new("I, Robot", 3)
    @not_same_class = Movie.new("I, Robot", 1)
  end

  it "全く同じ値のオブジェクト" do
    (@a_book == @same_book).should be_true
    @a_book.equal?(@same_book).should be_false
  end

  it "違う値のオブジェクト" do
    (@a_book == @not_same_book).should be_false
  end

  it "一部違う値のオブジェクト" do
    (@a_book == @partial_diff_book).should be_false
  end

  it "クラスが違う" do
    (@a_book == @not_same_class).should be_false
  end

  it "nil同士" do
    (Book.new(nil, nil) == Book.new(nil, nil)).should be_true
  end

  class NoEqualityBook
    def initialize(title, index_no)
      @title = title
      @index_no = index_no
    end
  end

  it "equalityを定義しないクラスでは、参照によって同一か判断される" do
    no_equality_book = NoEqualityBook.new("I, Robot", 1)
    (@a_book == no_equality_book).should be_false

    no_equality_book2 = no_equality_book
    (no_equality_book == no_equality_book2).should be_true
  end
end

