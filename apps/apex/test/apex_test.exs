defmodule ApexTest do
  use ExUnit.Case
  doctest Apex

  test "greets the world" do
    assert Apex.hello() == :world
  end
end
