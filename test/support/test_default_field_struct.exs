defmodule MachineryTest.TestDefaultFieldStruct do
  import Ecto.Changeset
  use Ecto.Schema

  schema "test_default_field_structs" do
    field(:state, :string)
    timestamps()
  end

  @doc false
  def changeset(test_struct, attrs) do
    cast(test_struct, attrs, [:state])
  end
end
