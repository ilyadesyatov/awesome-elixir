defmodule Awesome.Worker do
  use GenServer

  alias AwesomeToolbox

  @github_link Application.get_env(:awesome, :link_for_parse)

  def start_link(_) do
    GenServer.start_link(__MODULE__, @github_link)
  end

  defp schedule_work do
    Process.send_after(self(), :kill_self, 60 * 60 * 1000)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:kill_self, state) do
    AwesomeToolbox.annotate_readme(state)
    {:stop, :normal, state}
  end
end
