defmodule MachineryTest do
  use ExUnit.Case
  doctest Machinery

  test "greets the world" do
    assert Machinery.hello() == :world
  end
end
