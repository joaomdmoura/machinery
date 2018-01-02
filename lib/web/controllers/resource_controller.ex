defmodule Machinery.ResourceController do
  use Machinery.Web, :controller
  import Ecto.Query

  @items_per_page 50

  def index(conn, %{"state" => state, "page" => page} = _params) do
    repo = conn.assigns.repo
    model = conn.assigns.model
    page = String.to_integer(page)
    resources = get_resources_for_state(repo, model, state, page)
    json(conn, resources)
  end

  def index(conn, _params) do
    repo = conn.assigns.repo
    model = conn.assigns.model
    machinery_module = conn.assigns.module

    states = machinery_module._machinery_states()
    states_and_resources = Enum.map(states, fn(state) ->
      resources = get_resources_for_state(repo, model, state)
      %{name: state, resources: resources}
    end)

    friendly_module_name = to_string(model)
      |> String.split(".")
      |> List.last

    conn
      |> assign(:states, states_and_resources)
      |> assign(:friendly_module_name, friendly_module_name)
      |> render("index.html")
  end

  defp get_resources_for_state(repo, model, state, page \\ 1) do
    fields =  model.__schema__(:fields)
    query = from resource in model,
      select: map(resource, ^fields),
      where: resource.state == ^state,
      limit: @items_per_page,
      offset: ^(@items_per_page * (page - 1))

    repo.all(query)
  end
end
