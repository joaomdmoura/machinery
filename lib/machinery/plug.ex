defmodule Machinery.Plug do
  @moduledoc """
  This Plug module is the entry point for the Machinery Dashboard.
  It's supposed to be used on the Endpoint of a Phoenix application,
  and it's responsible to call the Machinery.Endpoint.

  You're expected to use this as a plug on the main application, and it also
  accepts an optional parameter that is the path you want to mount the
  Machinery dashboard if it's other than `/machinery`.

  ## Parameters
    - `path`: A string with the path you want to mount the dashboard
              if other than `/machinery`.

  ## Example
    ```
    defmodule YourProject.Endpoint do
      plug Machinery.Plug
    end
    ```
  """
  import Plug.Conn

  @default_path "/machinery"

  @doc false
  def init(default), do: default

  @doc """
  call/2 Intercepts the request as a plug and check if it matches with the
  defined path passed as argument, if it does it moves on calling the
  process/2 that will prepare the request and pass it through the
  Machinery.Endpoint.
  """
  def call(conn, [] = _path), do: call(conn, @default_path, matches?(conn, @default_path))
  def call(conn, path), do: call(conn, path, matches?(conn, path))
  def call(conn, path, true), do: process(conn, path)
  def call(conn, _path, false), do: conn

  @doc """
  Function responsible for redirect the request to Machinery.Endpoint.
  """
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
