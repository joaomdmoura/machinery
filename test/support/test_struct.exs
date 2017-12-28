defmodule MachineryTest.TestStruct do
  import Ecto.Changeset
  use Ecto.Schema

  schema "test_structs" do
    field :state, :string
    field :missing_fields, :boolean
    field :force_exception, :boolean
    timestamps()
  end

  @doc false
  def changeset(test_struct, attrs) do
    test_struct
    |> cast(attrs, [:state, :missing_fields, :force_exception])
  end
end
