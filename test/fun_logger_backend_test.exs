defmodule FunLoggerBackendTest do
  use ExUnit.Case
  doctest FunLoggerBackend

  test "greets the world" do
    assert FunLoggerBackend.hello() == :world
  end
end
