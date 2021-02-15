defmodule ScrapeServer.Scheduler do
  use GenServer
  require Logger

  # client api

  def start_link(_opts), do: GenServer.start(__MODULE__, [])

  # callbacks

  def init(_) do
    schedule()
    {:ok, %{}}
  end

  def handle_info(:runchecks, state) do
    runchecks()
    schedule()
    {:noreply, state}
  end

  # internal api

  defp runchecks do
    Logger.info "running checks"
  end

  defp schedule, do: Process.send_after(self(), :runchecks, Application.get_env(:scrape_server, :freq_millis))
end
