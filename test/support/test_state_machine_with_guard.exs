defmodule MachineryTest.TestStateMachineWithGuard do
  use Machinery,
    states: ["created", "partial", "completed"],
    transitions: %{
      "created" => ["partial", "completed"],
      "partial" => "completed"
    }

  def guard_transition(struct, "completed") do
    # Code to simulate and force an exception inside a
    # guard function.
    if Map.get(struct, :force_exception) do
      Machinery.non_existing_function_should_raise_error()
    end

    Map.get(struct, :missing_fields) == false
  end
end
