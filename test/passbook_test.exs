defmodule PassbookTest do
  use ExUnit.Case
  doctest Passbook

  describe "" do
  end

  test "it generates a pkpass file" do
    assert Passbook.hello() == :world
  end
end
