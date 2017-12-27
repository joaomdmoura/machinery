defmodule Machinery.Transitions do
  @moduledoc """
  This is a GenServer that controls the transitions for a struct
  using a set of helper functions from Machinery.Transition
  It's meant to be run by a supervisor.
  """

  use GenServer
  alias Machinery.Transition

  @not_declated_error "Transition to this state isn't declared."
  @guarded_error "Transition not completed, blocked by guard function."

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc false
  def handle_call({:run, struct, state_machine_module, next_state}, _from, states) do
    initial_state = state_machine_module._machinery_initial_state()
    transitions = state_machine_module._machinery_transitions()

    # Getting current state of the struct or falling back to the
    # first declared state on the struct model.
    current_state = case Map.get(struct, :state) do
      nil -> initial_state
      current_state -> current_state
    end

    # Checking declared transitions and guard functions before
    # actually updating the struct and retuning the tuple.
    response = cond do
      !Transition.declared_transition?(transitions, current_state, next_state) ->
        {:error, @not_declated_error}

      !Transition.guarded_transition?(state_machine_module, struct, next_state) ->
        {:error, @guarded_error}

      true ->
        struct = struct
          |> Transition.before_callbacks(next_state, state_machine_module)
          |> Transition.persist_struct(next_state, state_machine_module)
          |> Transition.after_callbacks(next_state, state_machine_module)
        {:ok, struct}
    end
    {:reply, response, states}
  end
end
