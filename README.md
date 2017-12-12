# Machinery

[![Build Status](https://travis-ci.org/joaomdmoura/machinery.svg?branch=master)](https://travis-ci.org/joaomdmoura/machinery)
[![Coverage Status](https://coveralls.io/repos/github/joaomdmoura/machinery/badge.svg?branch=master)](https://coveralls.io/github/joaomdmoura/machinery?branch=master)
[![Ebert](https://ebertapp.io/github/joaomdmoura/machinery.svg)](https://ebertapp.io/github/joaomdmoura/machinery)

![Machinery](https://github.com/joaomdmoura/machinery/blob/master/logo.png)

Machinery is a State Machine library for structs in general that integrates with
Pheonix out of the box.
It also aims to have (when implemented with Phoenix) an optional build-in GUI
that will represent each resource's state.

Don't forget to check the [Machinery Docs](https://hexdocs.pm/machinery)

- [Installing](#installing)
- [Declaring States](#declaring-states)
- [Changing States](#changing-states)
- [Guard Functions](#guard-functions)
- [Before and After Callbacks](#before-and-after-callbacks)


## Installing

The package can be installed by adding `machinery` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:machinery, "~> 0.4.0"}
  ]
end
```

## Declaring States

Declare the states you need pasing it as an argment when importing `Machinery`
on the module that will control your states transitions.

Machinery expects a `Keyword` as argument with two keys `states` and `transitions`.

- `states`: A List of Atoms representing each state.
- `transitions`: A List of Maps, including two keys `from` and `to`, `to` might be an Atom or a List of Atoms.

### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    # The first state declared will be considered the intial state
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }
end
```

## Changing States

To transit a struct into another state, you just need to call `Machinery.transition_to/2`

### `Machinery.transition_to/2`
It takes two arguments:

- `struct`: The struct you want to transit to another state
- `next_event`: An atom representing the next state you want the struct to transition to

```elixir
Machinery.transition_to(your_struct, :next_state)
# {:ok, updated_struct}
```

### Example:

```elixir
user = Accounts.get_user!(1)
UserStateMachine.transition_to(user, :partial)
```

Guard functions, before and after callbacks will be checked automatically.

## Guard functions
Create guard conditions by adding signatures of the `guard_transition/2`
function, pattern matching the desired state you want to guard.

Guard conditions should return a boolean:
  - `true`: Guard clause will allow the transition.
  - `false`: Transition won't be allowed.

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    # The first state declared will be considered the intial state
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }

  def guard_transition(struct, :complete) do
   Map.get(struct, :missing_fields) == false
  end
end
```

## Before and After callbacks

You can also use before and after callbacks to handle desired side effects and
reactions to a specific state transition, the implementation is pretty similar to
guard functions, you can just declare `before_transition/2` and ``after_transition/2`.
Before and After callbacks should return the struct being manipulated.

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    # The first state declared will be considered the intial state
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }

   def before_transition(struct, :partial) do
      # ... overall desired side effect
      struct
    end

    def after_transition(struct, :completed) do
      # ... overall desired side effect
      struct
    end
end
```