defmodule Machinery do
  @moduledoc """
  This is the main Machinery module.

  It keeps most of the Machinery logics, it's the module that will be
  imported with `use` on the module responsible for the state machine.

  Declare the states as an argument when importing `Machinery` on the module
  that will control your states transitions.

  Machinery expects a `Keyword` as argument with two keys `states` and `transitions`.

  - `states`: A List of Atoms representing each state.
  - `transitions`: A Map for each state and it allowed next state(s).

  ## Parameters

    - `opts`: A Keyword including `states` and `transitions`.
      - `states`: A List of Atoms representing each state.
      - `transitions`: A Map for each state and it allowed next state(s).

  ## Example
    ```
    defmodule YourProject.UserStateMachine do
      use Machinery,
        # The first state declared will be considered
        # the intial state
        states: [:created, :partial, :complete],
        transitions: %{
          created: [:partial, :complete],
          partial: :completed
        }
    end
    ```
  """

  alias Machinery.Transition

  @not_declated_error "Transition to this state isn't declared."
  @guarded_error "Transition not completed, blocked by guard function."

  @doc """
  Main macro function that will be executed upon the load of the
  module using it.

  It basically stores the states and transitions.

  It expects a `Keyword` as argument with two keys `states` and `transitions`.

  - `states`: A List of Atoms representing each state.
  - `transitions`: A Map for each state and it allowed next state(s).

  P.S. The first state declared will be considered the intial state
  """
  defmacro __using__(opts) do
    states = Keyword.get(opts, :states)
    transitions = Keyword.get(opts, :transitions)

    # Quoted response to be inserted on the abstract syntax tree (AST) of
    # the module that imported this using `use`.
    quote bind_quoted: [
      states: states,
      transitions: transitions
    ] do

      # Functions to hold and expose internal info of the states.
      def _machinery_initial_state(), do: List.first(unquote(states))
      def _machinery_states(), do: unquote(states)
      def _machinery_transitions(), do: unquote(Macro.escape(transitions))
    end
  end

  @doc """
  Triggers the transition of a struct to a new state, accordinly to a specific
  state machine module, if it passes any existing guard functions.
  It also runs any before or after callbacks and returns a tuple with
  `{:ok, struct}`, or `{:error, "reason"}`.

  ## Parameters

    - `struct`: The `struct` you want to transit to another state.
    - `state_machine_module`: The module that holds the state machine logic, where Machinery as imported.
    - `next_state`: Atom of the next state you want to transition to.

  ## Examples

      Machinery.transition_to(%User{state: :partial}, UserStateMachine, :completed)
      {:ok, %User{state: :completed}}
  """
  @spec transition_to(struct, module, atom) :: {:ok, struct} | {:error, String.t}
  def transition_to(struct, state_machine_module, next_state) do
    initial_state = state_machine_module._machinery_initial_state()
    transitions = state_machine_module._machinery_transitions()

    # Getting current state of the struct of falling back to the
    # first declared state on the struct model.
    current_state = case Map.get(struct, :state) do
      nil -> initial_state
      current_state -> current_state
    end

    # Checking declared transitions and guard functions before
    # actually updating the struct and retuning the tuple.
    cond do
      !Transition.declared_transition?(transitions, current_state, next_state) ->
        {:error, @not_declated_error}

      !Transition.guarded_transition?(state_machine_module, struct, next_state) ->
        {:error, @guarded_error}

      true ->
        struct = struct
          |> Transition.before_callbacks(next_state, state_machine_module)
          |> Map.put(:state, next_state)
          |> Transition.after_callbacks(next_state, state_machine_module)
        {:ok, struct}
    end
  end
end
