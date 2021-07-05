defmodule ScrapeServer.Notifier do
  require Logger

  def notify(url, message) do
    Logger.info "notifying change url=#{url}"

    slack_url = Application.get_env(:scrape_server, :slack_endpoint)

    if slack_url do
      HTTPoison.post(
        slack_url,
        Jason.encode!(%{text: "Something changed at #{url}\n#{message}"}),
        %{"Content-Type" => "application/json"}
      )
    end
  end
end
