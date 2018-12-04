defmodule MachineryTest.TestStruct do
  import Ecto.Changeset
  use Ecto.Schema

  schema "test_structs" do
    field :my_state, :string
    field :missing_fields, :boolean
    field :force_exception, :boolean
    timestamps()
  end

  @doc false
  def changeset(test_struct, attrs) do
    cast(test_struct, attrs, [:my_state, :missing_fields, :force_exception])
  end
end
