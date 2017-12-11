defmodule Machinery do
  @moduledoc """
  Main Machinery module.
  It keeps the bunk of the Machinery logics, it's the module that
  will be imported with `use` on the module that the state machine will
  be implemented.

  ## Parameters

    - `opts`: A Keyword including `states` and `transitions`.
      - `states`: A List of Atoms representing each state.
      - `transitions`: A List of Maps, including two keys `from` and `to`, `to` might be an Atom or a List of Atoms.

  ## Example
    ```
    defmodule Project.User do
      use Machinery,
        states: [:created, :partial, :complete],
        transitions: [
          %{from: :created, to: [:partial, :complete]},
          %{from: :partal, to: :complete}
        ]
    end
    ```
  """

  alias Machinery.Transition

  @not_declated_error "Transition to this state isn't declared."
  @guarded_error "Transition not completed, blocked by guard function."

  @doc """
  Main macro function that will be executed upon the load of the
  module using it.

  It basically stores the states and transition
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
  Triggers the transition of a struct to a new state if it passes the
  existing guard clause, also runs any before or after callbacks.
  It returns a tuple with `{:ok, state}`, or `{:error, "cause"}`.

  ## Parameters

    - `struct`: A Struct based on a module using Machinery.
    - `next_state`: Atom of the next state you want to transition to.

  ## Examples

      Machinery.transition_to(%User{state: :partial}, :completed)
      {:ok, %User{state: :completed}}
  """
  @spec transition_to(struct, atom) :: {:ok, struct} | {:error, String.t}
  def transition_to(struct, next_state) do
    module = struct.__struct__
    initial_state = module._machinery_initial_state()
    transitions = module._machinery_transitions()

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

      Transition.guarded_transition?(module, struct, next_state) ->
        {:error, @guarded_error}

      true ->
        struct = Map.put(struct, :state, next_state)
        {:ok, struct}
    end
  end
end
