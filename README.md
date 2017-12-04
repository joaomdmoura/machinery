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

After installing Machinery as a dependency you should declare the states you
will have on the module you want.

You should do it when declaring the `use` of `Machinery`, making sure to pass a
`Keyword` as argument with two keys `states` and `transitions`.

- states: A List of Atoms representing each state.
- transitions: A List of Maps, including two keys `from` and `to`, to might be an Atom or a List of Atoms.

For now you will also be required to create a new function on the same module
that will pattern match all transitions as a guard clause, this fuction should
be `defp guard_transition(_struct, _state), do: true`.
You can add other functions with the same signature using pattern match for the
state you want to guard.

### Example

```elixir
defmodule YourProject.User do

  use Machinery,
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }

  # You can implement guard conditions by adding new
  # signatures of the guard_transition/2 function
  # pattern matching the desired states you want to guard.
  #
  # Return true and the guard clause will allow the transition
  # Return false and the transition won't be allowed
  #
  defp guard_transition(struct, :complete) do
   Map.get(struct, :missing_fields) == false
  end

  # REQUIRED: It's required for you to include this function.
  # it will act as fallback for states that don't have guard functions.
  defp guard_transition(_struct, _state), do: true
end
```

## Usage

In order to transit a struct into another state, you just need to call the
`Module.transition_to(your_struct, :next_state)`.

### Example

```elixir
user = Accounts.get_user!(1)
User.transition_to(user, :partial)
```

Guard functions will be checked automatically.