defmodule Awesome.Worker do
  use GenServer

  alias AwesomeToolbox

  @github_link Application.get_env(:awesome, :link_for_parse)

  def start_link(_) do
    {:ok, queue} = initial_queue(@github_link)
    GenServer.start_link(__MODULE__, queue)
  end

  defp schedule_work do
    Process.send_after(self(), :work, 3 * 1000)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, queue) do
    queue =
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          queue = queue_2
          queue = process(item, queue)
          queue
        _ ->
          IO.puts "Empty queue."
          Process.sleep(20 * 60 * 1000)
          {:ok, queue} = initial_queue(@github_link)
          queue
      end
    schedule_work()
    {:noreply, queue}
  end

  def process(package, queue) do
    with {:ok, stars, update_ago} <- AwesomeToolbox.GithubParser.package_info(package.link) do
      changes = %{stars: stars, updated_days_ago: update_ago}
      {:ok, updated_package} = AwesomeToolbox.update_package(package, changes)
    end
    queue
  end

  def initial_queue(link) do
    {:ok, result} = AwesomeToolbox.annotate_readme(link)
    queue = :queue.from_list(result)
    {:ok, queue}
  end
end
