defmodule Machinery.Transition do
  @moduledoc """
  Machinery module responsible for control transitions,
  guard functions and callbacks (before and after).
  It's meant to be for internal use only.
  """

  @doc """
  Function responsible for checking if the transition from a state to another
  was specifically declared.
  """
  @spec declared_transition?(list, atom, atom) :: boolean
  def declared_transition?(transitions, current_state, next_state) do
    case Map.fetch(transitions, current_state) do
      {:ok, [_|_] = declared_states} -> Enum.member?(declared_states, next_state)
      {:ok, declared_state} -> declared_state == next_state
      :error -> false
    end
  end

  @doc """
  Default guard transition fallback to make sure all transitions are permitted
  unless another existing guard condition exists.
  """
  @spec guarded_transition?(module, struct, atom) :: boolean
  def guarded_transition?(module, struct, next_state) do
    !module.guard_transition(struct, next_state)
  rescue
    error in UndefinedFunctionError -> guard_transition_fallback?(error)
    error in FunctionClauseError -> guard_transition_fallback?(error)
  end

  def run_before_callbacks(struct, state, module) do
    module.before_transition(struct, state)
  rescue
    error in UndefinedFunctionError -> callbacks_fallback(struct, error)
    error in FunctionClauseError -> callbacks_fallback(struct, error)
  end

  def run_after_callbacks(struct, state, module) do
    module.after_transition(struct, state)
  rescue
    error in UndefinedFunctionError -> callbacks_fallback(struct, error)
    error in FunctionClauseError -> callbacks_fallback(struct, error)
  end

  defp callbacks_fallback(struct, error) do
    if error.function in [:after_transition, :before_transition] && error.arity == 2 do
      struct
    else
      raise error
    end
  end

  # If the exception passed id related to a specific signature of
  # guard_transition/2 it will fallback returning true and
  # allwoing the transition, otherwise it will raise the exception.
  defp guard_transition_fallback?(error) do
    if error.function == :guard_transition && error.arity == 2 do
      false
    else
      raise error
    end
  end
end
