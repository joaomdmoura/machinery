defmodule Machinery.Transition do
  @moduledoc """
  Machinery module responsible for control transitions,
  guard functions and callbacks (before and after).
  This is meant to be for internal use only.
  """

  @doc """
  Function responsible for checking if the transition from a state to another
  was specifically declared.
  This is meant to be for internal use only.
  """
  @spec declared_transition?(list, atom, atom) :: boolean
  def declared_transition?(transitions, current_state, next_state) do
    if matches_wildcard?(transitions, next_state) do
      true
    else
      matches_transition?(transitions, current_state, next_state)
    end
  end

  @doc """
  Default guard transition fallback to make sure all transitions are permitted
  unless another existing guard condition exists.
  This is meant to be for internal use only.
  """
  @spec guarded_transition?(module, struct, atom, map) :: boolean
  def guarded_transition?(module, struct, state, extra) do
    # IO.puts "guarded_transition?\n#{inspect(module)}\n#{inspect(struct)}\n#{inspect(state)}\n#{inspect(extra)}"
    case run_or_fallback(
           &module.guard_transition/3,
           &guard_transition_fallback/4,
           struct,
           state,
           module._field(),
           extra
         ) do
      {:error, cause} -> {:error, cause}
      _ -> false
    end
  end

  @doc """
  Function responsible to run all before_transitions callbacks or
  fallback to a boilerplate behaviour.
  This is meant to be for internal use only.
  """
  @spec before_callbacks(struct, atom, module, map) :: struct
  def before_callbacks(struct, state, module, extra) do
    run_or_fallback(
      &module.before_transition/3,
      &callbacks_fallback/4,
      struct,
      state,
      module._field(),
      extra
    )
  end

  @doc """
  Function responsible to run all after_transitions callbacks or
  fallback to a boilerplate behaviour.
  This is meant to be for internal use only.
  """
  @spec after_callbacks(struct, atom, module, map) :: struct
  def after_callbacks(struct, state, module, extra) do
    run_or_fallback(
      &module.after_transition/3,
      &callbacks_fallback/4,
      struct,
      state,
      module._field(),
      extra
    )
  end

  @doc """
  This function will try to trigger persistence, if declared, to the struct
  changing state.
  This is meant to be for internal use only.
  """
  @spec persist_struct(struct, atom, module, any) :: struct
  def persist_struct(struct, state, module, extra) do
    run_or_fallback(&module.persist/3, &persist_fallback/4, struct, state, module._field(), extra)
  end

  @doc """
  Function resposible for triggering transitions persistence.
  This is meant to be for internal use only.
  """
  @spec log_transition(struct, atom, module, map) :: struct
  def log_transition(struct, state, module, extra) do
    run_or_fallback(
      &module.log_transition/3,
      &log_transition_fallback/4,
      struct,
      state,
      module._field(),
      extra
    )
  end

  defp matches_wildcard?(transitions, next_state) do
    matches_transition?(transitions, "*", next_state)
  end

  defp matches_transition?(transitions, current_state, next_state) do
    case Map.fetch(transitions, current_state) do
      {:ok, [_ | _] = declared_states} -> Enum.member?(declared_states, next_state)
      {:ok, declared_state} -> declared_state == next_state
      :error -> false
    end
  end

  # Private function that receives a function, a callback,
  # a struct and the related state. It tries to execute the function,
  # rescue for a couple of specific Exceptions and passes it forward
  # to the callback, that will re-raise it if not related to
  # guard_transition nor before | after call backs
  defp run_or_fallback(func, callback, struct, state, field, extra) do
    func.(struct, state, extra)
  rescue
    error in UndefinedFunctionError ->
      callback.(struct, state, error, field)
    error in FunctionClauseError -> callback.(struct, state, error, field)
  end

  defp persist_fallback(struct, state, error, field) do
    if error.function == :persist && error.arity == 3 do
      Map.put(struct, field, state)
    else
      raise error
    end
  end

  defp log_transition_fallback(struct, _state, error, _field) do
    if error.function == :log_transition && error.arity == 3 do
      struct
    else
      raise error
    end
  end

  defp callbacks_fallback(struct, _state, error, _field) do
    if error.function in [:after_transition, :before_transition] && error.arity == 3 do
      struct
    else
      raise error
    end
  end

  # If the exception passed is related to a specific signature of
  # guard_transition/3 it will fallback returning true and
  # allwoing the transition, otherwise it will raise the exception.
  defp guard_transition_fallback(_struct, _state, error, _field) do
    if error.function == :guard_transition && error.arity == 3 do
      true
    else
      raise error
    end
  end
end
