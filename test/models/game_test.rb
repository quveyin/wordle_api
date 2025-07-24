require 'test_helper'

class GameTest < ActiveSupport::TestCase
  test "should require secret word" do
    game = Game.new(attempts_count: 0)
    assert_not game.save
  end

  test "should validate secret word length" do
    game = Game.new(secret_word: "TOO", attempts_count: 0)
    assert_not game.valid?
  end

  test "should validate guesses" do
    game = Game.create!(secret_word: "CRANE", attempts_count: 0)
    assert game.valid_guess?("CRANE")
    assert_not game.valid_guess?("TOOLONG")
  end
end