# Machinery

[![Build Status](https://travis-ci.org/joaomdmoura/machinery.svg?branch=master)](https://travis-ci.org/joaomdmoura/machinery)
[![Coverage Status](https://coveralls.io/repos/github/joaomdmoura/machinery/badge.svg?branch=master)](https://coveralls.io/github/joaomdmoura/machinery?branch=master)
[![Ebert](https://ebertapp.io/github/joaomdmoura/machinery.svg)](https://ebertapp.io/github/joaomdmoura/machinery)

![Machinery](https://github.com/joaomdmoura/machinery/blob/master/logo.png)

Machinery is a thin State Machine library that integrates with
Phoenix out of the box.

It's just a small layer that provides a DSL for declaring states
and having guard clauses + callbacks for structs in general.
It also aims to have (when implemented with Phoenix) an optional
build-in GUI that will represent each resource's state.


### Do you always need a process to be a state machine?
Yes? This is not your library. You might be better off with
another library or even `gen_statem` or `gen_fsm` from Erlang/OTP.

Don't forget to check the [Machinery Docs](https://hexdocs.pm/machinery)

- [Installing](#installing)
- [Declaring States](#declaring-states)
- [Changing States](#changing-states)
- [Guard Functions](#guard-functions)
- [Before and After Callbacks](#before-and-after-callbacks)

![gif example](https://imgur.com/xR3D640.gif)


## Installing

The package can be installed by adding `machinery` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:machinery, "~> 0.4.1"}
  ]
end
```

Create a field `state` for the module you want to have a state machine,
make sure you have declared it as part of you `defstruct`, or if it
is a Phoenix model make sure you add it to the `schema`, as a `string`,  and
to the `changeset/2`:

```elixir
defmodule YourProject.YouModule do
  schema "users" do
    # ...
    field :state, :string
    # ...
  end

  def changeset(%User{} = user, attrs) do
    #...
    |> cast(attrs, [:state])
    #...
  end
end
```

## Declaring States

Declare the states as an argment when importing `Machinery` on the module that
will control your states transitions.

Machinery expects a `Keyword` as argument with two keys `states` and `transitions`.

- `states`: A List of Atoms representing each state.
- `transitions`: A Map for each state and it allowed next state(s).

### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    # The first state declared will be considered
    # the intial state
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }
end
```

## Changing States

To transit a struct into another state, you just need to call `Machinery.transition_to/2`.

### `Machinery.transition_to/2`
It takes two arguments:

- `struct`: The `struct` you want to transit to another state.
- `next_event`: An `atom` of the next state you want the struct to transition to.

**Guard functions, before and after callbacks will be checked automatically.**

```elixir
Machinery.transition_to(your_struct, :next_state)
# {:ok, updated_struct}
```

### Example:

```elixir
user = Accounts.get_user!(1)
UserStateMachine.transition_to(user, :partial)
```

## Guard functions
Create guard conditions by adding signatures of the `guard_transition/2`
function, pattern matching the desired state you want to guard.

```elixir
def guard_transition(struct, :state), do: true
```

Guard conditions should return a boolean:
  - `true`: Guard clause will allow the transition.
  - `false`: Transition won't be allowed.

### Example:

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    states: [:created, :complete],
    transitions: %{created: :complete}

  # Guard the transition to the :complete state.
  def guard_transition(struct, :complete) do
   Map.get(struct, :missing_fields) == false
  end
end
```

## Before and After callbacks

You can also use before and after callbacks to handle desired side effects and
reactions to a specific state transition.

You can just declare `before_transition/2` and `  after_transition/2`,
pattern matching the desired state you want to.

**Make sure Before and After callbacks should return the struct.**

```elixir
# callbacks should always return the struct.
def before_transition(struct, :state), do: struct
def after_transition(struct, :state), do: struct
```

### Example:

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    states: [:created, :partial, :complete],
    transitions: %{
      created: [:partial, :complete],
      partial: :completed
    }

    def before_transition(struct, :partial) do
      # ... overall desired side effects
      struct
    end

    def after_transition(struct, :completed) do
      # ... overall desired side effects
      struct
    end
end
```
