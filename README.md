# Machinery

[![Build Status](https://circleci.com/gh/joaomdmoura/machinery.svg?style=svg)](https://circleci.com/gh/circleci/circleci-docs)
[![Module Version](https://img.shields.io/hexpm/v/machinery.svg)](https://hex.pm/packages/machinery)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/machinery/)
[![Total Download](https://img.shields.io/hexpm/dt/machinery.svg)](https://hex.pm/packages/machinery)
[![License](https://img.shields.io/hexpm/l/machinery.svg)](https://github.com/joaomdmoura/machinery/blob/master/LICENSE)

![Machinery](./assets/logo.png)

Machinery is a lightweight State Machine library for Elixir with built-in
Phoenix integration.
It provides a simple DSL for declaring states and includes support for guard
clauses and callbacks.

## Table of Contents
- [Installing](#installing)
- [Declaring States](#declaring-states)
- [Changing States](#changing-states)
- [Persist State](#persist-state)
- [Logging Transitions](#logging-transitions)
- [Guard Functions](#guard-functions)
- [Before and After Callbacks](#before-and-after-callbacks)

## Installing

Add `:machinery` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:machinery, "~> 1.1.0"}
  ]
end
```

Create a `state` field (or a custom name) for the module you want to apply a
state machine to, and ensure it's declared as part of your defstruct.

If using a Phoenix model, add it to the schema as a `string` and include it in
the `changeset/2` function:

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

Create a separate module for your State Machine logic.
For example, if you want to add a state machine to your `User` model, create a
`UserStateMachine` module.

Then import `Machinery` in this new module and declare states as arguments.

Machinery expects a `Keyword` as an argument with the keys `field`, `states`
and `transitions`.

- `field`: An atom representing your state field name (defaults to `state`)
- `states`: A `List` of `t:Machinery.state/0`s representing each state.
- `transitions`: A Map for each state and its allowed next state(s).

### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    field: :custom_state_name, # Optional, default value is `:field`
    states: ["created", "partial", "completed", "canceled"],
    transitions: %{
      "created" =>  ["partial", "completed"],
      "partial" => "completed",
      "*" => "canceled"
    }
end
```

You can use wildcards `"*"` to declare a transition that can happen from any
state to a specific one.

## Changing States

To transition a struct to another state, call `Machinery.transition_to/3` or `Machinery.transition_to/4`.

### `Machinery.transition_to/3` or ``Machinery.transition_to/4`

It takes the following arguments:

- `struct`: The `struct` you want to transition to another state.
- `state_machine_module`: The module that holds the state machine logic, where Machinery is imported.
- `next_event`: `t:Machinery.state/0` of the next state you want the struct to transition to.
- *(optional)* `extra_metadata`: `map` with any extra data you might want to access on any of the sate machine functions triggered by the state change

```elixir
Machinery.transition_to(your_struct, YourStateMachine, "next_state")
# {:ok, updated_struct}

# OR

Machinery.transition_to(your_struct, YourStateMachine, "next_state", %{extra: "metadata"})
# {:ok, updated_struct}
```

### Example

```elixir
user = Accounts.get_user!(1)
{:ok, updated_user} = Machinery.transition_to(user, UserStateMachine, "completed")
```

## Persist State

To persist the struct and state transition, you declare a `persist/2` or `/3` *(in case you wanna access metadata passed on `transition_to/4`)*
function in the state machine module.

This function will receive the unchanged `struct` as the first argument and a
`t:Machinery.state/0` of the next state as the second one.

**your `persist/2` or `persist/3` should always return the updated struct.**

### Note on `atom()` states and persistence

You may need to deal with deserializing your states if working with `t:atom/0` `t:Machinery.state/0`s and Ecto as `t:atom/0`s will be stored in the database as
`t:String.t/0`s.
If you aren't using persistence, this won't be a problem.

### Example

```elixir
defmodule YourProject.UserStateMachine do
  alias YourProject.Accounts

  use Machinery,
    states: ["created", "completed"],
    transitions: %{"created" => "completed"}

  # You can add an optional third argument for the extra metadata.
  def persist(struct, next_state) do
    # Updating a user on the database with the new state.
    {:ok, user} = Accounts.update_user(struct, %{state: next_stated})
    # `persist` should always return the updated struct
    user
  end
end
```

## Logging Transitions

To log transitions, Machinery provides a `log_transition/2` or `/3` *(in case you wanna access metadata passed on `transition_to/4`)*
callback that is called on every transition, after the `persist` function is executed.

This function receives the unchanged `struct` as the first
argument and a `t:Machinery.state/0` of the next state as the second one.

**`log_transition/2` or `log_transition/3` should always return the struct.**

### Example

```elixir
defmodule YourProject.UserStateMachine do
  alias YourProject.Accounts

  use Machinery,
    states: ["created", "completed"],
    transitions: %{"created" => "completed"}

  # You can add an optional third argument for the extra metadata.
  def log_transition(struct, _next_state) do
    # Log transition here.
    # ...
    # `log_transition` should always return the struct
    struct
  end
end
```

## Guard functions

Create guard conditions by adding `guard_transition/2` or `/3` *(in case you wanna access metadata passed on `transition_to/4`)*
function signatures to the state machine module.
This function receives two arguments: the `struct` and a `t:Machinery.state/0` of the state it
will transition to.

Use the second argument for pattern matching the desired state you want to guard.

```elixir
# The second argument is used to pattern match into the state
# and guard the transition to it.
#
# You can add an optional third argument for the extra metadata.
def guard_transition(struct, "guarded_state") do
 # Your guard logic here
end
```

Guard conditions will allow the transition if it returns anything other than a tuple with `{:error, "cause"}`:
  - `{:error, "cause"}`: Transition won't be allowed.
  - `_` *(anything else)*: Guard clause will allow the transition.

### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    states: ["created", "completed"],
    transitions: %{"created" => "completed"}

  # Guard the transition to the "completed" state.
  def guard_transition(struct, "completed") do
    if Map.get(struct, :missing_fields) == true do
      {:error, "There are missing fields"}
    end
  end
end
```

When trying to transition a struct that is blocked by its guard clause,
you will have the following return:

```elixir
blocked_struct = %TestStruct{state: "created", missing_fields: true}
Machinery.transition_to(blocked_struct, TestStateMachineWithGuard, "completed")

# {:error, "There are missing fields"}
```

## Before and After callbacks

You can also use before and after callbacks to handle desired side effects and
reactions to a specific state transition.

You can declare `before_transition/2` or `/3` *(in case you wanna access metadata passed on `transition_to/4`)*
and `after_transition/2` or `/3` *(in case you wanna access metadata passed on `transition_to/4`)*,
pattern matching the desired state you want to.

**Before and After callbacks should return the struct.**

```elixir
# Before and After callbacks should return the struct.
# You can add an optional third argument for the extra metadata.
def before_transition(struct, "state"), do: struct
def after_transition(struct, "state"), do: struct
```

### Example

```elixir
defmodule YourProject.UserStateMachine do
  use Machinery,
    states: ["created", "partial", "completed"],
    transitions: %{
      "created" =>  ["partial", "completed"],
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

## Copyright and License

Copyright (c) 2016 João M. D. Moura

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
