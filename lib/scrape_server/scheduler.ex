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

    ScrapeServer.Database.url_stream
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
      {:changed, true} -> process_change(url)
      _ -> :noop
    end
  end

  defp process_change(url) do
    Logger.info "notifying change url=#{url}"

    HTTPoison.post(
      Application.get_env(:scrape_server, :slack_endpoint),
      Jason.encode!(%{text: "something at #{url} changed"}),
      %{"Content-Type" => "application/json"}
    )

    :ok
  end

  defp schedule, do: Process.send_after(self(), :runchecks, Application.get_env(:scrape_server, :freq_millis))
end
