defmodule Mix.Tasks.Css.Selector do
  use Mix.Task
  @shortdoc "css.selector prints the inner html of the selector applied to the url"

  @impl Mix.Task
  @spec run(nonempty_maybe_improper_list) :: any
  def run([url, selector]) do
    Application.ensure_all_started :hackney

    {:ok, html} = ScrapeServer.Fetcher.fetch url
    {:ok, doc} = Floki.parse_document html

    Mix.shell().info "parsed representation"

    doc
    |> Floki.find(selector)
    |> IO.inspect

    Mix.shell().info "as text"

    doc
    |> Floki.find(selector)
    |> Enum.map(&Floki.text/1)
    |> Enum.map(&String.trim/1)
  end
end
