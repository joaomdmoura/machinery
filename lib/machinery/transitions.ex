defmodule Machinery.Transitions do
  @moduledoc """
  This is a GenServer that controls the transitions for a struct
  using a set of helper functions from Machinery.Transition
  It's meant to be run by a supervisor.
  """

  use GenServer
  alias Machinery.Transition

  @not_declated_error "Transition to this state isn't declared."

  def init(args) do
    {:ok, args}
  end

  @doc false
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc false
  def handle_call({:run, struct, state_machine_module, next_state, extra_metadata}, _from, states) do
    initial_state = state_machine_module._machinery_initial_state()
    transitions = state_machine_module._machinery_transitions()
    state_field = state_machine_module._field()

    # Getting current state of the struct or falling back to the
    # first declared state on the struct model.
    current_state =
      case Map.get(struct, state_field) do
        nil -> initial_state
        current_state -> current_state
      end

    # Checking declared transitions and guard functions before
    # actually updating the struct and retuning the tuple.
    declared_transition? = Transition.declared_transition?(transitions, current_state, next_state)

    response =
      if declared_transition? do
        guarded_transition? =
          Transition.guarded_transition?(state_machine_module, struct, next_state, extra_metadata)

        if guarded_transition? do
          guarded_transition?
        else
          struct =
            struct
            |> Transition.before_callbacks(next_state, state_machine_module, extra_metadata)
            |> Transition.persist_struct(next_state, state_machine_module, extra_metadata)
            |> Transition.log_transition(next_state, state_machine_module, extra_metadata)
            |> Transition.after_callbacks(next_state, state_machine_module, extra_metadata)

          {:ok, struct}
        end
      else
        {:error, @not_declated_error}
      end

    {:reply, response, states}
  end
end
