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
  end

  test "All transition_to methods for each state were injected into AST" do
    assert :erlang.function_exported(TestModule, :transition_to, 2)
    assert TestModule.transition_to(%{}, :created)
    assert TestModule.transition_to(%{}, :partial)
    assert TestModule.transition_to(%{}, :completed)
  end

  test "Only the declared transitions should be valid" do
    assert {:ok, %{state: :partial}} = TestModule.transition_to(%{state: :created}, :partial)
    assert {:ok, %{state: :completed}} = TestModule.transition_to(%{state: :created}, :completed)
    assert {:ok, %{state: :completed}} = TestModule.transition_to(%{state: :partial}, :completed)
    assert {:error, "Transition to this state isn't allowed"} = TestModule.transition_to(%{}, :created)
    assert {:error, "Transition to this state isn't allowed"} = TestModule.transition_to(%{state: :completed}, :created)
  end
end
