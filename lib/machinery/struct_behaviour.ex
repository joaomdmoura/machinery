defmodule Machinery.StructBehaviour do
  @moduledoc """
  Behaviour that will be implemented in the module of the struct
  using Machinery
  """

  @callback guard_transition(struct, atom) :: boolean
end
