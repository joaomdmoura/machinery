defmodule MachineryTest.TestRepo do
  alias MachineryTest.TestStruct

  def all(_), do: [%{id: 1}, %{id: 2}, %{id: 3}]
end
