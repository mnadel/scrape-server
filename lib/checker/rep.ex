defmodule Checker.Rep do
  @derive [Checker]
  def contents(html) do
    case Floki.parse_document html do
      {:ok, doc} -> doc
        |> Floki.find("ol.products div.product-item-info")
        |> Enum.filter(&(String.contains?(Floki.raw_html(&1), "tocart-form")))
        |> Enum.map(&(Floki.find(&1, "a.product-item-link")))
        |> Enum.map(&Floki.text/1)
        |> Enum.map(&String.trim/1)
        |> Enum.sort
        |> Enum.join("\n")
      _ ->
        "error parsing"
    end
  end

  def message(url, contents), do: "items in stock at #{url}:\n#{contents}"
end
