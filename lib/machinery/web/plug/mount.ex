defmodule Machinery.Plug.Mount do
  import Plug.Conn

  def init(default), do: default

  def call(conn, path),         do: call(conn, path, matches?(conn, path))
  def call(conn, path, true),   do: process(conn, path)
  def call(conn, _path, false), do: conn

  def process(conn, path) do
    conn
      |> assign(:mount_path, path)
      |> forward(path)
      |> halt
  end

  defp path_segments(path) do
    String.split(path, "/") |> Enum.reject(fn(x)-> x == "" end)
  end

  defp matches?(conn, path) do
    String.starts_with?(conn.request_path, path)
  end

  defp forward(conn, path) do
    conn |> Phoenix.Router.Route.forward(path_segments(path), Machinery.Endpoint,[])
  end
end
