defmodule MachineryTest.TestRepo do
  alias MachineryTest.TestStruct

  def all(_), do: [%TestStruct{}, %TestStruct{}, %TestStruct{}]
end
