defmodule CosmosTest do
  use ExUnit.Case
  doctest Cosmos

  test "greets the world" do
    assert Cosmos.hello() == :world
  end
end
