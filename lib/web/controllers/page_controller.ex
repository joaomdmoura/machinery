defmodule Machinery.PageController do
  use Machinery.Web, :controller
  import Ecto.Query

  def index(conn, _params) do
    repo = conn.assigns.repo
    model = conn.assigns.model
    machinery_module = conn.assigns.module

    states = machinery_module._machinery_states()
    |> Enum.map(fn(state) ->
      query = from resource in model,
         where: resource.state == ^state,
         select: resource
      %{name: state, resources: repo.all(query)}
    end)

    friendly_module_name = to_string(machinery_module)
      |> String.split(".")
      |> List.last

    conn
      |> assign(:states, states)
      |> assign(:friendly_module_name, friendly_module_name)
      |> render("index.html")
  end
end
