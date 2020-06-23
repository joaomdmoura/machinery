defmodule MachineryTest.TestStateMachineWithGuard do
  use Machinery,
    field: :my_state,
    states: ["created", "partial", "completed"],
    transitions: %{
      "created" => ["partial", "completed"],
      "partial" => "completed"
    }

  def guard_transition(struct, "completed", _extra) do
    # Code to simulate and force an exception inside a
    # guard function.
    if Map.get(struct, :force_exception) do
      IO.inspect "raising"
      Machinery.non_existing_function_should_raise_error()
    end

    no_missing_fields = Map.get(struct, :missing_fields) == false

    unless no_missing_fields do
      {:error, "Guard Condition Custom Cause"}
    end
  end

  def log_transition(struct, _next_state, _extra) do
    # Log transition here
    if Map.get(struct, :force_exception) do
      Machinery.non_existing_function_should_raise_error()
    end

    struct
  end
end
