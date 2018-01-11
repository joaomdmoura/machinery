defmodule MachineryTest.TestRepo do
  @doc """
  Simulating a lame fake kind-broken pagination for test purposes.
  """
  def all(%{offset: offset}) do
    [{offset_number, :integer}] = offset.params
    all_resources = all(nil)
    if offset_number > Enum.count(all_resources) do
      []
    else
      all_resources
    end
  end
  def all(_), do: [%{id: 1}, %{id: 2}, %{id: 3}]

  def get!(_model, id) do
    %{id: id}
  end
end
