defmodule ApexRedisStreamerTest do
  use ExUnit.Case
  doctest ApexRedisStreamer

  test "greets the world" do
    assert ApexRedisStreamer.hello() == :world
  end
end
