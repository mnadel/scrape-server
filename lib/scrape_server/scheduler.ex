defmodule ScrapeServer.Scheduler do
  use GenServer
  require Logger

  # client api

  def start_link(_opts), do: GenServer.start(__MODULE__, [], name: :scheduler)

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

    Application.get_env(:scrape_server, :checks)
      |> Enum.each(&check/1)
  end

  defp check({url, checker}) do
    Logger.info "checking url=#{url}, checker=#{checker}"

    case ScrapeServer.Fetcher.fetch(url) do
      {:ok, html} -> check(url, html, checker)
      {:error, error} -> Logger.error "error fetching url=#{url}, error=#{error}"
    end
  end

  defp check(url, html, checker) do
    contents = apply(checker, :contents, [html])
    message = apply(checker, :message, [url, contents])

    case ScrapeServer.Database.check(url, contents) do
      {:changed, true} -> ScrapeServer.Notifier.notify(url, message)
      _ -> :noop
    end
  end

  defp schedule, do: Process.send_after(self(), :runchecks, Application.get_env(:scrape_server, :freq_millis))
end
