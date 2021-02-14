defmodule ScrapeServer.Fetcher do
  @notfound_resp {:error, :notfound}

  def fetch(url), do: fetch(url, 0)

  defp fetch(:notfound, _), do: @notfound_resp

  defp fetch(_, redirect_count) when redirect_count > 5, do: {:error, :toomanyredirects}

  defp fetch(url, redirect_count) do
    case url |> HTTPoison.get do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 301, headers: headers}} ->
        location_header = headers
          |> Enum.find(@notfound_resp, &("Location" = elem(&1, 0)))
        url = elem(location_header, 1)
        fetch(url, redirect_count + 1)
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
