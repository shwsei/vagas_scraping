defmodule WebscrapingTest do
  use ExUnit.Case
  doctest Webscraping

  test "greets the world" do
    assert Webscraping.hello() == :world
  end
end
