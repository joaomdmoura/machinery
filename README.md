# Machinery

[![Build Status](https://travis-ci.org/joaomdmoura/machinery.svg?branch=master)](https://travis-ci.org/joaomdmoura/machinery)
[![Coverage Status](https://coveralls.io/repos/github/joaomdmoura/machinery/badge.svg?branch=master)](https://coveralls.io/github/joaomdmoura/machinery?branch=master)
[![Ebert](https://ebertapp.io/github/joaomdmoura/machinery.svg)](https://ebertapp.io/github/joaomdmoura/machinery)

![Machinery](https://github.com/joaomdmoura/machinery/blob/master/logo.png)

Machinery is a State Machine library for structs in general that integrates with
Pheonix out of the box.
It also aims to have (when implemented with Phoenix) an optional build-in GUI
that will represent each resource's state.

Check proper [Machinery Docs](https://hexdocs.pm/machinery)

## Installation

The package can be installed by adding `machinery` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:machinery, "~> 0.2.0"}
  ]
end
```

### Declaring States

Declare the states you need pasing it as an argment when importing `Machinery`
on the module that will control your states transitions.

Machinery expects a `Keyword` as argument with two keys `states` and `transitions`.

- states: A List of Atoms representing each state.
- transitions: A List of Maps, including two keys `from` and `to`, `to` might be an Atom or a List of Atoms.

#### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    # The first state declared will be considered the intial state
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }

  # Create guard conditions by adding new signatures
  # of the guard_transition/2 function, pattern matching
  # the desired state you want to guard.
  #
  # Guard conditions should return a boolean:
  # true: Guard clause will allow the transition
  # false: Transition won't be allowed
  #
  def guard_transition(struct, :complete) do
   Map.get(struct, :missing_fields) == false
  end

  ############
  # REQUIRED: It's required for you to include this function.
  # it will act as fallback for states that don't have guard functions.
  # Allowing their transitons to go through
  ############
  def guard_transition(_struct, _state), do: true
end
```

## Usage

To transit a struct into another state, you just need to call `Machinery.transition_to/2`
```elixir
Machinery.transition_to(your_struct, :next_state)
```

### Example

```elixir
user = Accounts.get_user!(1)
UserStateMachine.transition_to(user, :partial)
```

Guard functions will be checked automatically.