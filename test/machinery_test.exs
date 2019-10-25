defmodule MachineryTest do
  use ExUnit.Case, async: false
  doctest Machinery

  alias MachineryTest.Helper
  alias MachineryTest.TestDefaultFieldStruct
  alias MachineryTest.TestStateMachine
  alias MachineryTest.TestStateMachineDefaultField
  alias MachineryTest.TestStateMachineWithGuard
  alias MachineryTest.TestStruct

  setup do
    Helper.machinery_interface()
  end

  test "All internal functions should be injected into AST" do
    assert :erlang.function_exported(TestStateMachine, :_machinery_initial_state, 0)
    assert :erlang.function_exported(TestStateMachine, :_machinery_states, 0)
    assert :erlang.function_exported(TestStateMachine, :_machinery_transitions, 0)
    assert :erlang.function_exported(TestStateMachine, :_field, 0)
  end

  test "Only the declared transitions should be valid" do
    created_struct = %TestStruct{my_state: "created", missing_fields: false}
    partial_struct = %TestStruct{my_state: "partial", missing_fields: false}
    stateless_struct = %TestStruct{}
    completed_struct = %TestStruct{my_state: "completed"}

    assert {:ok, %TestStruct{my_state: "partial"}} =
             Machinery.transition_to(created_struct, TestStateMachine, "partial")

    assert {:ok, %TestStruct{my_state: "completed", missing_fields: false}} =
             Machinery.transition_to(created_struct, TestStateMachine, "completed")

    assert {:ok, %TestStruct{my_state: "completed", missing_fields: false}} =
             Machinery.transition_to(partial_struct, TestStateMachine, "completed")

    assert {:error, "Transition to this state isn't declared."} =
             Machinery.transition_to(stateless_struct, TestStateMachine, "created")

    assert {:error, "Transition to this state isn't declared."} =
             Machinery.transition_to(completed_struct, TestStateMachine, "created")
  end

  test "Wildcard transitions should be valid" do
    created_struct = %TestStruct{my_state: "created", missing_fields: false}
    partial_struct = %TestStruct{my_state: "partial", missing_fields: false}
    completed_struct = %TestStruct{my_state: "completed"}

    assert {:ok, %TestStruct{my_state: "canceled", missing_fields: false}} =
             Machinery.transition_to(created_struct, TestStateMachine, "canceled")

    assert {:ok, %TestStruct{my_state: "canceled", missing_fields: false}} =
             Machinery.transition_to(partial_struct, TestStateMachine, "canceled")

    assert {:ok, %TestStruct{my_state: "canceled"}} =
             Machinery.transition_to(completed_struct, TestStateMachine, "canceled")
  end

  test "Guard functions should be executed before moving the resource to the next state" do
    struct = %TestStruct{my_state: "created", missing_fields: true}

    assert {:error, _cause} =
             Machinery.transition_to(struct, TestStateMachineWithGuard, "completed")
  end

  test "Guard functions should allow or block transitions" do
    allowed_struct = %TestStruct{my_state: "created", missing_fields: false}
    blocked_struct = %TestStruct{my_state: "created", missing_fields: true}

    assert {:ok, %TestStruct{my_state: "completed", missing_fields: false}} =
             Machinery.transition_to(allowed_struct, TestStateMachineWithGuard, "completed")

    assert {:error, _cause} =
             Machinery.transition_to(blocked_struct, TestStateMachineWithGuard, "completed")
  end

  test "Guard functions should return an error cause" do
    blocked_struct = %TestStruct{my_state: "created", missing_fields: true}

    assert {:error, "Guard Condition Custom Cause"} =
             Machinery.transition_to(blocked_struct, TestStateMachineWithGuard, "completed")
  end

  test "The first declared state should be considered the initial one" do
    stateless_struct = %TestStruct{}

    assert {:ok, %TestStruct{my_state: "partial"}} =
             Machinery.transition_to(stateless_struct, TestStateMachine, "partial")
  end

  test "Modules without guard conditions should allow transitions by default" do
    struct = %TestStruct{my_state: "created"}

    assert {:ok, %TestStruct{my_state: "completed"}} =
             Machinery.transition_to(struct, TestStateMachine, "completed")
  end

  @tag :capture_log
  test "Implict rescue on the guard clause internals should raise any other excepetion not strictly related to missing guard_tranistion/2 existence" do
    wrong_struct = %TestStruct{my_state: "created", force_exception: true}

    assert_raise UndefinedFunctionError, fn ->
      Machinery.transition_to(wrong_struct, TestStateMachineWithGuard, "completed")
    end
  end

  test "after_transition/2 and before_transition/2 callbacks should be automatically executed" do
    struct = %TestStruct{}
    assert struct.missing_fields == nil

    {:ok, partial_struct} = Machinery.transition_to(struct, TestStateMachine, "partial")
    assert partial_struct.missing_fields == true

    {:ok, completed_struct} = Machinery.transition_to(struct, TestStateMachine, "completed")
    assert completed_struct.missing_fields == false
  end

  @tag :capture_log
  test "Implict rescue on the callbacks internals should raise any other excepetion not strictly related to missing callbacks_fallback/2 existence" do
    wrong_struct = %TestStruct{my_state: "created", force_exception: true}

    assert_raise UndefinedFunctionError, fn ->
      Machinery.transition_to(wrong_struct, TestStateMachine, "partial")
    end
  end

  test "Persist function should be called after the transition" do
    struct = %TestStruct{my_state: "partial"}
    assert {:ok, _} = Machinery.transition_to(struct, TestStateMachine, "completed")
  end

  @tag :capture_log
  test "Persist function should still raise errors if not related to the existence of persist/1 method" do
    wrong_struct = %TestStruct{my_state: "created", force_exception: true}

    assert_raise UndefinedFunctionError, fn ->
      Machinery.transition_to(wrong_struct, TestStateMachine, "completed")
    end
  end

  @tag :capture_log
  test "Transition log function should still raise errors if not related to the existence of persist/1 method" do
    wrong_struct = %TestStruct{my_state: "created", force_exception: true}

    assert_raise UndefinedFunctionError, fn ->
      Machinery.transition_to(wrong_struct, TestStateMachineWithGuard, "partial")
    end
  end

  test "Transition log function should be called after the transition" do
    struct = %TestStruct{my_state: "created"}
    assert {:ok, _} = Machinery.transition_to(struct, TestStateMachineWithGuard, "partial")
  end

  @tag :capture_log
  test "Machinery.Transitions GenServer should be started under the Machinery.Supervisor" do
    transitions_pid = Process.whereis(Machinery.Transitions)
    assert Process.alive?(transitions_pid)
  end

  test "Should use default state name if not specified" do
    struct = %TestDefaultFieldStruct{state: "created"}

    assert {:ok, %TestDefaultFieldStruct{state: "canceled"}} =
             Machinery.transition_to(struct, TestStateMachineDefaultField, "canceled")
  end
end
