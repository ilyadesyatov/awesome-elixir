defmodule Awesome.Worker do
  use GenServer

  alias AwesomeToolbox

  @github_link Application.get_env(:awesome, :link_for_parse)

  def start_link(_) do
    {:ok, queue, tuple_readme} = initial_queue(@github_link)
    GenServer.start_link(__MODULE__, {queue, tuple_readme})
  end

  defp schedule_work do
    Process.send_after(self(), :work, 3 * 1000)
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, {queue, tuple_readme}) do
    {queue, tuple_readme} =
      case :queue.out(queue) do
        {{_value, item}, queue_2} ->
          queue = queue_2
          queue = process(item, queue, tuple_readme)
          {queue, tuple_readme}
        _ ->
          IO.puts "Empty queue."
          Process.sleep(20 * 60 * 1000)
          {:ok, queue, tuple_readme} = initial_queue(@github_link)
          {queue, tuple_readme}
      end
    schedule_work()
    {:noreply, {queue, tuple_readme}}
  end

  def process({:section_name, name}, queue, tuple_readme) do
    {:ok, section} = AwesomeToolbox.create_section(name, tuple_readme)
    {:ok, packages} = AwesomeToolbox.section_packages(section.name, tuple_readme)

    queue = Enum.reduce(packages, queue, fn package, queue ->
      :queue.in({:package_name, {package, section.id}}, queue)
    end)
    queue
  end

  def process({:package_name, {name, section_id}}, queue, _tuple_readme) do
    AwesomeToolbox.package(name, section_id)
    queue
  end

  def initial_queue(link) do
    {:ok, tuple_readme, sections_parse_result} = AwesomeToolbox.annotate_readme(link)
    sections = sections_parse_result |> Enum.map(fn(element) ->
      {:section_name, hd elem(element, 2)}
    end)
    queue = :queue.from_list(sections)
    {:ok, queue, tuple_readme}
  end
end
