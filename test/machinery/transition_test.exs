defmodule MachineryTest.TransitionTest do
  use ExUnit.Case, async: false
  doctest Machinery.Transition
  alias Machinery.Transition

  test "declared_transition?/3 based on a map of transitions, current and next state" do
    transitions = %{
      "created" => ["partial", "completed"],
      "partial" => "completed"
    }
    assert Transition.declared_transition?(transitions, "created", "partial")
    assert Transition.declared_transition?(transitions, "created", "completed")
    assert Transition.declared_transition?(transitions, "partial", "completed")
    refute Transition.declared_transition?(transitions, "partial", "created")
  end

  test "declared_transition?/3 for a declared transition that allows transition for any state" do
    transitions = %{
      "created" => "completed",
      "*" =>"canceled"
    }
    assert Transition.declared_transition?(transitions, "created", "completed")
    assert Transition.declared_transition?(transitions, "created", "canceled")
    assert Transition.declared_transition?(transitions, "completed", "canceled")
  end
end
