defmodule Machinery.Plug do
  @moduledoc """
  This Plug module is the entry point for the Machinery Dashboard.
  It's supposed to be used on the Endpoint of a Phoenix application,
  and it's responsible to call the Machinery.Endpoint.
  """
  import Plug.Conn

  def init(default), do: default

  def call(conn, path: path), do: call(conn, path, matches?(conn, path))
  def call(conn, path, true), do: process(conn, path)
  def call(conn, _path, false), do: conn

  def process(conn, path) do
    module = Application.get_env(:machinery, :module)
    model = Application.get_env(:machinery, :model)
    repo = Application.get_env(:machinery, :repo)

    conn
      |> assign(:mount_path, path)
      |> assign(:module, module)
      |> assign(:model, model)
      |> assign(:repo, repo)
      |> forward(path)
      |> halt
  end

  defp path_segments(path) do
    path
      |> String.split("/")
      |> Enum.reject(fn(x) -> x == "" end)
  end

  defp matches?(conn, path) do
    String.starts_with?(conn.request_path, path)
  end

  defp forward(conn, path) do
    Phoenix.Router.Route.forward(conn, path_segments(path), Machinery.Endpoint, [])
  end
end
