defmodule MachineryTest do
  use ExUnit.Case
  alias MachineryTest.TestModule
  doctest Machinery

  defmodule TestModule do
    use Machinery,
      states: [:created, :partial, :completed],
      transitions: %{
        created: [:partial, :completed],
        partial: :completed
      }

    defp guard_transition(struct, :completed) do
      Map.get(struct, :missing_fields) == false
    end
    defp guard_transition(_struct, _state), do: true
  end

  test "All transition_to methods for each state were injected into AST" do
    assert :erlang.function_exported(TestModule, :transition_to, 2)
    assert TestModule.transition_to(%{}, :created)
    assert TestModule.transition_to(%{}, :partial)
    assert TestModule.transition_to(%{}, :completed)
  end

  test "Only the declared transitions should be valid" do
    assert {:ok, %{state: :partial}} = TestModule.transition_to(%{state: :created}, :partial)
    assert {:ok, %{state: :completed, missing_fields: false}} = TestModule.transition_to(%{state: :created, missing_fields: false}, :completed)
    assert {:ok, %{state: :completed, missing_fields: false}} = TestModule.transition_to(%{state: :partial, missing_fields: false}, :completed)
    assert {:error, "Transition to this state isn't allowed"} = TestModule.transition_to(%{}, :created)
    assert {:error, "Transition to this state isn't allowed"} = TestModule.transition_to(%{state: :completed}, :created)
  end

  test "Guard functions should be executed before moving the resource to the next state" do
    struct = %{state: :created, missing_fields: true}
    assert {:error, "Transition not completed, blocked by guard function"} = TestModule.transition_to(struct, :completed)
  end

  test "The first declared state should be considered the initial one" do
    stateless_struct = %{}
    assert {:ok, %{state: :partial}} = TestModule.transition_to(stateless_struct, :partial)
  end
end
