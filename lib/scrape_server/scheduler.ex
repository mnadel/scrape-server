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

    ScrapeServer.Database.urls
    |> Stream.each(&(check(&1)))
    |> Stream.run
  end

  defp check(url) do
    Logger.info "checking url=#{url}"

    case ScrapeServer.Fetcher.fetch(url) do
      {:ok, contents} -> check(url, contents)
      {:error, error} -> Logger.error "error fetching url=#{url}, error=#{error}"
    end
  end

  def check(url, contents) do
    check = ScrapeServer.Database.check(url, contents)
    case check do
      {:changed, true} -> ScrapeServer.Notifier.notify(url, contents)
      _ -> :noop
    end
  end

  defp schedule, do: Process.send_after(self(), :runchecks, Application.get_env(:scrape_server, :freq_millis))
end
