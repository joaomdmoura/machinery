defmodule MachineryTest.PlugTest do
  use ExUnit.Case, async: false
  use Plug.Test
  alias MachineryTest.Helper

  setup_all do
    Helper.machinery_interface()
  end

  @tag :capture_log
  test "Machinery.Plug should not touch the request if it does not match the defined path" do
    conn = Machinery.Plug.call(conn(:get, "/non-machinery-route"), "/machinery-route")
    assert conn.state == :unset
  end

  @tag :capture_log
  test "Machinery.Plug should send the request to Machinery.ResourceControlller the if `interface` is set as true" do
    conn = Machinery.Plug.call(conn(:get, "/"), "/")
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.private.phoenix_controller == Machinery.ResourceController
  end

  @tag :capture_log
  test "Machinery.Plug should fall back to its default path defined as `/machinery` if none is provided" do
    conn = Machinery.Plug.call(conn(:get, "/machinery"), [])
    assert conn.state == :sent
    assert conn.status == 200
    assert conn.private.phoenix_controller == Machinery.ResourceController
  end
end
