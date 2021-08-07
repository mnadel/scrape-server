defmodule ScrapeServer.Fetcher do
  @notfound_resp {:error, :notfound}

  def fetch(url, headers \\ []), do: fetch(url, headers, 0)

  defp fetch(:notfound, _, _), do: @notfound_resp

  defp fetch(_, _, redirect_count) when redirect_count > 5, do: {:error, :toomanyredirects}

  defp fetch(url, headers, redirect_count) do
    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 301, headers: resp_headers}} ->
        location_header = resp_headers
          |> Enum.find(@notfound_resp, &("Location" == elem(&1, 0)))
        url = elem(location_header, 1)
        fetch(url, headers, redirect_count + 1)
      {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
        {:error, code, body}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
