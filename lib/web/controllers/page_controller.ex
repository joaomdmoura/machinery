defmodule Machinery.PageController do
  use Machinery.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
