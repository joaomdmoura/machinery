defmodule Machinery do
  @moduledoc """
  Main Machinery module.
  It keeps the bunk of the Machinery logics, it's the module that
  will be imported with `use` on the module that the state machine will
  be implemented.

  ## Parameters

    - opts: A Keyword including `states` and `transitions`.
      - states: A List of Atoms representing each state.
      - transitions: A List of Maps, including two keys `from` and `to`, to might be an Atom or a List of Atoms.

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
    quote bind_quoted: [states: states, transitions: transitions] do
      @unallowed_transition_error "Transition to this state isn't allowed"
      @guarded_transition_error "Transition not completed, blocked by guard function"

      # Mapping the declared states to create the functions for each one.
      Enum.each(states, fn(state) ->
        @doc """
        Triggers the transition of a struct to a new state if it passes the
        existing guard clause, also runs any before or after callbacks.
        It returns a tuple with {:ok, state}, or {:error, "cause"}.

        ## Parameters

          - struct: A Struct based on a module using Machinery.
          - next_state: Atom of the next state you want to transition to.

        ## Examples

            iex> User.transition_to(%User{state: partial}, :completed)
            {:ok, %User{state: completed}}

        """
        def transition_to(struct, unquote(state) = next_state) do
          current_state = Map.get(struct, :state)
          cond do
            !allowed_transition?(current_state, next_state) ->
              {:error, @unallowed_transition_error}
            !guard_transition(struct, next_state) ->
              {:error, @guarded_transition_error}
            true ->
              struct = Map.put(struct, :state, next_state)
              {:ok, struct}
          end
        end
      end)

      defp allowed_transition?(current_state, next_state) do
        case Map.fetch(unquote(Macro.escape(transitions)), current_state) do
          {:ok, [_|_] = allowed_states} -> Enum.member?(allowed_states, next_state)
          {:ok, allowed_state} -> allowed_state == next_state
          :error -> false
        end
      end
    end
  end
end
