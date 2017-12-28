defmodule MachineryTest.PageControllerTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import ExUnit.CaptureLog

  setup_all do
    Application.put_env(:machinery, :module, MachineryTest.TestStateMachine)
    Application.put_env(:machinery, :model, MachineryTest.TestStruct)
    Application.put_env(:machinery, :repo, MachineryTest.TestRepo)
    Application.put_env(:machinery, :interface, true)
    capture_log fn ->
      MachineryTest.Helper.restart_machinery()
    end
    :ok
  end

  @tag :capture_log
  test "Dasboard should be accessible if `interface` is set as true" do
    conn = conn(:get, "/")
    |> Machinery.Plug.call("/")

    assert conn.state == :sent
    assert conn.status == 200
  end
end
