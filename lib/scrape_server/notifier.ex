defmodule ScrapeServer.Notifier do
  require Logger

  def notify(url, contents) do
    Logger.info "notifying change url=#{url}"

    slack_url = Application.get_env(:scrape_server, :slack_endpoint)
    if slack_url, do: post(slack_url, url, contents)
  end

  def post(slack_url, url, _contents) do
    HTTPoison.post(
      slack_url,
      Jason.encode!(%{text: "something at #{url} changed"}),
      %{"Content-Type" => "application/json"}
    )
  end
end
