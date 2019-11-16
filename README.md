# Machinery

[![Build Status](https://travis-ci.org/joaomdmoura/machinery.svg?branch=master)](https://travis-ci.org/joaomdmoura/machinery)
[![Source Level](https://app.sourcelevel.io/github/joaomdmoura/machinery.svg)](https://app.sourcelevel.io/github/joaomdmoura/machinery)
[![Coverage Status](https://coveralls.io/repos/github/joaomdmoura/machinery/badge.svg?branch=master)](https://coveralls.io/github/joaomdmoura/machinery?branch=master)

![Machinery](https://github.com/joaomdmoura/machinery/blob/master/logo.png)

Machinery is a thin State Machine library for Elixir that integrates with
Phoenix out of the box.

It's just a small layer that provides a DSL for declaring states
and having guard clauses + callbacks for structs in general.

### Do you always need a state machine to be a process?
Yes? This is not your library. You might be better off with
another library or even `gen_statem` or `gen_fsm` from Erlang/OTP.

Don't forget to check the [Machinery Docs](https://hexdocs.pm/machinery)

- [Installing](#installing)
- [Declaring States](#declaring-states)
- [Changing States](#changing-states)
- [Persist State](#persist-state)
- [Logging Transitions](#logging-transitions)
- [Guard Functions](#guard-functions)
- [Before and After Callbacks](#before-and-after-callbacks)

## Installing

The package can be installed by adding `machinery` to your list of
dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:machinery, "~> 0.17.0"}
  ]
end
```

Create a field `state` (or a name of your choice to be defined later) for the
module you want to have a state machine, make sure you have declared it as part
of you `defstruct`, or if it is a Phoenix model make sure you add it to the `schema`,
as a `string`,  and to the `changeset/2`:

```elixir
defmodule YourProject.User do
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

Declare the states as an argument when importing `Machinery` on the module that
will control your states transitions.

It's strongly recommended that you create a new module for your State Machine
logic. So let's say you want to add it to your `User` model, you should create a
`UserStateMachine` module to hold your State Machine logic.

Machinery expects a `Keyword` as argument with the keys `field`, `states` and `transitions`.

- `field`: An atom of your state field name (defaults to `state`)
- `states`: A List of Strings representing each state.
- `transitions`: A Map for each state and it allowed next state(s).

### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    # This is a way to define a custom field, if not defined
    # it will expect the default `state` field in the struct
    field: :custom_state_name,
    # The first state declared will be considered
    # the initial state.
    states: ["created", "partial", "complete", "canceled"],
    transitions: %{
      "created" =>  ["partial", "complete"],
      "partial" => "completed",
      "*" => "canceled"
    }
end
```

As you might notice you can use wildcards `"*"` to declare a transition that
can happen from any state to a specific one.

## Changing States

To transit a struct into another state, you just need to
call `Machinery.transition_to/3`.

### `Machinery.transition_to/3`
It takes three arguments:

- `struct`: The `struct` you want to transit to another state.
- `state_machine_module`: The module that holds the state machine logic, where Machinery as imported.
- `next_event`: `string` of the next state you want the struct to transition to.

**Guard functions, before and after callbacks will be checked automatically.**

```elixir
Machinery.transition_to(your_struct, YourStateMachine, "next_state")
# {:ok, updated_struct}
```

### Example:

```elixir
user = Accounts.get_user!(1)
Machinery.transition_to(user, UserStateMachine, "complete")
```

## Persist State
To persist the struct and the state transition automatically, instead of having
Machinery changing the struct itself, you can declare a `persist/2` function on
the state machine module.

It will receive the unchanged `struct` as the first argument and a `string` of the
next state as the second one, after every state transition. That will be called
between the before and after transition callbacks.

**`persist/2` should always return the updated struct.**

### Example:

```elixir
defmodule YourProject.UserStateMachine do
  alias YourProject.Accounts

  use Machinery,
    states: ["created", "complete"],
    transitions: %{"created" => "complete"}

  def persist(struct, next_state) do
    # Updating a user on the database with the new state.
    {:ok, user} = Accounts.update_user(struct, %{state: next_state})
    user
  end
end
```

## Logging Transitions
To log/persist the transitions itself Machinery provides a callback
`log_transitions/2` that will be called on every transition.

It will receive the unchanged `struct` as the first argument and a `string` of
the next state as the second one, after every state transition.
This function will be called between the before and after transition callbacks
and after the persist function.

**`log_transition/2` should always return the updated struct.**

### Example:

```elixir
defmodule YourProject.UserStateMachine do
  alias YourProject.Accounts

  use Machinery,
    states: ["created", "complete"],
    transitions: %{"created" => "complete"}

  def log_transition(struct, _next_state) do
    # Log transition here, save on the DB or whatever.
    # ...
    # Return the struct.
    struct
  end
end
```

## Guard functions
Create guard conditions by adding signatures of the `guard_transition/2`
function, it will receive two arguments, the `struct` and an `string` of the
state it will transit to, use this second argument to pattern matching the
desired state you want to guard.

```elixir
# The second argument is used to pattern match into the state
# and guard the transition to it.
def guard_transition(struct, "guarded_state") do
 # Your guard logic here
end
```

Guard conditions will allow the transition if it returns anything other than a tuple with `{:error, "cause"}`:
  - `{:error, "cause"}`: Transition won't be allowed.
  - `_` *(anything else)*: Guard clause will allow the transition.

### Example:

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    states: ["created", "complete"],
    transitions: %{"created" => "complete"}

  # Guard the transition to the "complete" state.
  def guard_transition(struct, "complete") do
    if Map.get(struct, :missing_fields) == true do
      {:error, "There are missing fields"}
    end
  end
end
```

When trying to transition an struct that is blocked by its guard clause you will
have the following return:

```elixir
blocked_struct = %TestStruct{state: "created", missing_fields: true}
Machinery.transition_to(blocked_struct, TestStateMachineWithGuard, "completed")

# {:error, "There are missing fields"}
```

## Before and After callbacks

You can also use before and after callbacks to handle desired side effects and
reactions to a specific state transition.

You can just declare `before_transition/2` and `after_transition/2`,
pattern matching the desired state you want to.

**Make sure Before and After callbacks should return the struct.**

```elixir
# callbacks should always return the struct.
def before_transition(struct, "state"), do: struct
def after_transition(struct, "state"), do: struct
```

### Example:

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    states: ["created", "partial", "complete"],
    transitions: %{
      "created" =>  ["partial", "complete"],
      "partial" => "completed"
    }

    def before_transition(struct, "partial") do
      # ... overall desired side effects
      struct
    end

    def after_transition(struct, "completed") do
      # ... overall desired side effects
      struct
    end
end
```
