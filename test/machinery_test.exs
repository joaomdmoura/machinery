defmodule MachineryTest do
  use ExUnit.Case
  doctest Machinery

  alias MachineryTest.TestModule
  alias MachineryTest.TestModuleWithGuard

  defmodule TestModuleWithGuard do
    defstruct state: nil, missing_fields: nil, force_exception: false

    use Machinery,
      states: [:created, :partial, :completed],
      transitions: %{
        created: [:partial, :completed],
        partial: :completed
      }

    def guard_transition(struct, :completed) do

      # Code to unquote code into this AST that
      # will force and exception.
      if Map.get(struct, :force_exception) do
        Machinery.non_existing_function_should_raise_error()
      end

      Map.get(struct, :missing_fields) == false
    end
  end

  defmodule TestModule do
    defstruct state: nil, missing_fields: nil

    use Machinery,
      states: [:created, :partial, :completed],
      transitions: %{
        created: [:partial, :completed],
        partial: :completed
      }
  end

  test "All internal functions should be injected into AST" do
    assert :erlang.function_exported(TestModule, :_machinery_initial_state, 0)
    assert :erlang.function_exported(TestModule, :_machinery_states, 0)
    assert :erlang.function_exported(TestModule, :_machinery_transitions, 0)
  end

  test "Only the declared transitions should be valid" do
    created_struct = %TestModuleWithGuard{state: :created, missing_fields: false}
    partial_struct = %TestModuleWithGuard{state: :partial, missing_fields: false}
    stateless_struct = %TestModuleWithGuard{}
    completed_struct = %TestModuleWithGuard{state: :completed}

    assert {:ok, %TestModuleWithGuard{state: :partial}} = Machinery.transition_to(created_struct, :partial)
    assert {:ok, %TestModuleWithGuard{state: :completed, missing_fields: false}} = Machinery.transition_to(created_struct, :completed)
    assert {:ok, %TestModuleWithGuard{state: :completed, missing_fields: false}} = Machinery.transition_to(partial_struct, :completed)
    assert {:error, "Transition to this state isn't allowed"} = Machinery.transition_to(stateless_struct, :created)
    assert {:error, "Transition to this state isn't allowed"} = Machinery.transition_to(completed_struct, :created)
  end

  test "Guard functions should be executed before moving the resource to the next state" do
    struct = %TestModuleWithGuard{state: :created, missing_fields: true}
    assert {:error, "Transition not completed, blocked by guard function"} = Machinery.transition_to(struct, :completed)
  end

  test "Guard functions should allow or block transitions" do
    allowed_struct = %TestModuleWithGuard{state: :created, missing_fields: false}
    blocked_struct = %TestModuleWithGuard{state: :created, missing_fields: true}

    assert {:ok, %TestModuleWithGuard{state: :completed, missing_fields: false}} = Machinery.transition_to(allowed_struct, :completed)
    assert {:error, "Transition not completed, blocked by guard function"} = Machinery.transition_to(blocked_struct, :completed)
  end

  test "The first declared state should be considered the initial one" do
    stateless_struct = %TestModuleWithGuard{}
    assert {:ok, %TestModuleWithGuard{state: :partial}} = Machinery.transition_to(stateless_struct, :partial)
  end

  test "Modules without guard conditions should allow transitions by default" do
    struct = %TestModule{state: :created, missing_fields: true}
    assert {:ok, %TestModule{state: :completed, missing_fields: true}} = Machinery.transition_to(struct, :completed)
  end

  test "Implict rescue on the guard clause internals should raise any other excepetion not strictly related to missing guard_tranistion/2 existence" do
    wrong_struct = %TestModuleWithGuard{state: :created, force_exception: true}
    assert_raise UndefinedFunctionError, fn() ->
      Machinery.transition_to(wrong_struct, :completed)
    end
  end
end
