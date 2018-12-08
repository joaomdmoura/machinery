defmodule MachineryTest.TestStateMachineDefaultField do
  use Machinery,
    states: ["created", "canceled"],
    transitions: %{
      "*" => "canceled"
    }
end
