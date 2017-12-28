ExUnit.start()

# Load support modules
Code.load_file("test/support/test_struct.exs")
Code.load_file("test/support/test_state_machine.exs")
Code.load_file("test/support/test_state_machine_with_guard.exs")
Code.load_file("test/support/test_repo.exs")

defmodule MachineryTest.Helper do
  def restart_machinery() do
    supervisor_pid = Process.whereis(Machinery.Supervisor)
    Process.exit(supervisor_pid, :kill)
    :timer.sleep(100)
    Application.start(:machinery)
  end
end
