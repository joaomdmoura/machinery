defmodule Machinery do
  @moduledoc """
  This is the main Machinery module.

  It keeps most of the Machinery logics, it's the module that will be
  imported with `use` on the module responsible for the state machine.

  Declare the states as an argument when importing `Machinery` on the module
  that will control your states transitions.

  Machinery expects a `Keyword` as argument with two keys `states` and `transitions`.

  ## Parameters

    - `opts`: A Keyword including `states` and `transitions`.
      - `states`: A List of Strings representing each state.
      - `transitions`: A Map for each state and it allowed next state(s).

  ## Example
    ```
    defmodule YourProject.UserStateMachine do
      use Machinery,
        # The first state declared will be considered
        # the intial state
        states: ["created", "partial", "complete"],
        transitions: %{
          "created" =>  ["partial", "complete"],
          "partial" => "completed"
        }
    end
    ```
  """

  @doc """
  Main macro function that will be executed upon the load of the
  module using it.

  It basically stores the states and transitions.

  It expects a `Keyword` as argument with two keys `states` and `transitions`.

  - `states`: A List of Strings representing each state.
  - `transitions`: A Map for each state and it allowed next state(s).

  P.S. The first state declared will be considered the intial state
  """
  defmacro __using__(opts) do
    field = Keyword.get(opts, :field, :state)
    states = Keyword.get(opts, :states)
    transitions = Keyword.get(opts, :transitions)

    # Quoted response to be inserted on the abstract syntax tree (AST) of
    # the module that imported this using `use`.
    quote bind_quoted: [
            field: field,
            states: states,
            transitions: transitions
          ] do
      # Functions to hold and expose internal info of the states.
      def _machinery_initial_state(), do: List.first(unquote(states))
      def _machinery_states(), do: unquote(states)
      def _machinery_transitions(), do: unquote(Macro.escape(transitions))
      def _field(), do: unquote(field)
    end
  end

  @doc """
  Start function that will trigger a supervisor for the Machinery.Transitions, a
  GenServer that controls the state transitions.
  """
  def start(_type, _args) do
    children = [{Machinery.Transitions, name: Machinery.Transitions}]
    opts = [strategy: :one_for_one, name: Machinery.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  Triggers the transition of a struct to a new state, accordinly to a specific
  state machine module, if it passes any existing guard functions.
  It also runs any before or after callbacks and returns a tuple with
  `{:ok, struct}`, or `{:error, "reason"}`.

  ## Parameters

    - `struct`: The `struct` you want to transit to another state.
    - `state_machine_module`: The module that holds the state machine logic, where Machinery as imported.
    - `next_state`: String of the next state you want to transition to.

  ## Examples

      Machinery.transition_to(%User{state: :partial}, UserStateMachine, :completed)
      {:ok, %User{state: :completed}}
  """
  @spec transition_to(struct, module, String.t()) :: {:ok, struct} | {:error, String.t()}
  def transition_to(struct, state_machine_module, next_state, extra \\ %{}) do
    GenServer.call(Machinery.Transitions, {
      :run,
      struct,
      state_machine_module,
      next_state,
      extra
    }, :infinity)
  catch
    :exit, error_tuple ->
      exception = deep_first_of_tuple(error_tuple)
      raise exception
  end

  defp deep_first_of_tuple(tuple) when is_tuple(tuple) do
    tuple
    |> elem(0)
    |> deep_first_of_tuple
  end

  defp deep_first_of_tuple(value), do: value
end
