defmodule Checker.Rep do
  def contents(html) do
    {:ok, doc} = Floki.parse_document html
    doc
      |> Floki.find("ol.products div.product-item-info")
      |> Enum.filter(&(String.contains?(Floki.raw_html(&1), "tocart-form")))
      |> Enum.map(&(Floki.find(&1, "a.product-item-link")))
      |> Enum.map(&Floki.text/1)
      |> Enum.map(&String.trim/1)
      |> Enum.join("\n")
  end

  def message(url, contents), do: "items in stock at #{url}:\n#{contents}"
end
