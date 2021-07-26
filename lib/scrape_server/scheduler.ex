defmodule ScrapeServer.Scheduler do
  use GenServer
  require Logger

  # client api

  def start_link(_opts), do: GenServer.start(__MODULE__, [], name: :scheduler)

  def run_check(module), do: GenServer.call(:scheduler, {:check, module})

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

  def handle_call({:check, module}, _, state) do
    {:reply, check(module), state}
  end

  # internal api

  defp runchecks do
    Logger.info "running checks"

    checkers = with {:ok, list} <- :application.get_key(:scrape_server, :modules) do
      list
      |> Enum.filter(&(&1 |> Module.split |> Enum.take(1) == ~w|Checker|))
      |> Enum.filter(&(&1 |> Atom.to_string |> String.contains?(".Checker.")))
    end

    Logger.info "found checks=#{inspect(checkers)}"

    checkers
    |> Enum.each(&check/1)
  end

  defp check(checker) do
    url = checker.url(:noop)

    Logger.info "checking checker=#{checker}, url=#{url}"

    case ScrapeServer.Fetcher.fetch(url) do
      {:ok, html} -> check(url, html, checker)
      {:error, code, error} -> Logger.error "error fetching url=#{url}, code=#{code}, error=#{error}"
      {:error, error} -> Logger.error "error fetching url=#{url}, error=#{error}"
    end
  end

  defp check(url, html, checker) do
    contents = apply(checker, :contents, [html])

    case ScrapeServer.Database.check(url, contents) do
      {:changed, true} ->
        message = apply(checker, :message, [contents])
        ScrapeServer.Notifier.notify(url, message)
      _ -> :nochange
    end
  end

  defp schedule, do: Process.send_after(self(), :runchecks, Application.get_env(:scrape_server, :freq_millis))
end
