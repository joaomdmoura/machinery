defmodule MachineryTest.TestStateMachineWithExtraMetadata do
  use Machinery,
    field: :my_state,
    states: ["created", "partial", "completed", "canceled"],
    transitions: %{
      "created" => ["partial", "completed"],
      "partial" => "completed",
      "*" => "canceled"
    }

  def before_transition(struct, "partial", extra) do
    extra = Map.put(extra, :before_transition, true)
    struct = Map.merge(struct, extra)
    Map.put(struct, :missing_fields, true)
  end

  def after_transition(struct, "completed", extra) do
    extra = Map.put(extra, :after_transition, true)
    struct = Map.merge(struct, extra)
    Map.put(struct, :missing_fields, false)
  end

  def persist(struct, next_state, extra) do
    extra = Map.put(extra, :persist, true)
    struct = Map.merge(struct, extra)
    Map.put(struct, :my_state, next_state)
  end

  def log_transition(struct, _next_state, extra) do
    extra = Map.put(extra, :log, true)
    struct = Map.merge(struct, extra)
    Map.merge(struct, extra)
  end

  def guard_transition(struct, "completed", extra) do
    extra = Map.put(extra, :guard_transition, true)
    Map.merge(struct, extra)
  end
end
