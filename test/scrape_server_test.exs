defmodule ScrapeServerTest do
  use ExUnit.Case
  doctest ScrapeServer

  test "greets the world" do
    assert ScrapeServer.hello() == :world
  end
end
