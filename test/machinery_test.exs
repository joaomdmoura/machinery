defmodule MachineryTest do
  use ExUnit.Case
  alias MachineryTest.TestModule
  doctest Machinery

  defmodule TestModule do

    defstruct state: nil, missing_fields: nil

    use Machinery,
      states: [:created, :partial, :completed],
      transitions: %{
        created: [:partial, :completed],
        partial: :completed
      }

    def guard_transition(struct, :completed) do
      Map.get(struct, :missing_fields) == false
    end

    def guard_transition(_struct, _state), do: true
  end

  test "All internal functions should be injected into AST" do
    assert :erlang.function_exported(TestModule, :_machinery_initial_state, 0)
    assert :erlang.function_exported(TestModule, :_machinery_states, 0)
    assert :erlang.function_exported(TestModule, :_machinery_transitions, 0)
  end

  test "Only the declared transitions should be valid" do
    assert {:ok, %TestModule{state: :partial}} = Machinery.transition_to(%TestModule{state: :created}, :partial)
    assert {:ok, %TestModule{state: :completed, missing_fields: false}} = Machinery.transition_to(%TestModule{state: :created, missing_fields: false}, :completed)
    assert {:ok, %TestModule{state: :completed, missing_fields: false}} = Machinery.transition_to(%TestModule{state: :partial, missing_fields: false}, :completed)
    assert {:error, "Transition to this state isn't allowed"} = Machinery.transition_to(%TestModule{}, :created)
    assert {:error, "Transition to this state isn't allowed"} = Machinery.transition_to(%TestModule{state: :completed}, :created)
  end

  test "Guard functions should be executed before moving the resource to the next state" do
    struct = %TestModule{state: :created, missing_fields: true}
    assert {:error, "Transition not completed, blocked by guard function"} = Machinery.transition_to(struct, :completed)
  end

  test "The first declared state should be considered the initial one" do
    stateless_struct = %TestModule{}
    assert {:ok, %TestModule{state: :partial}} = Machinery.transition_to(stateless_struct, :partial)
  end
end
