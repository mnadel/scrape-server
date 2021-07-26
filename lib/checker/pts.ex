defmodule Checker.Pts do
  @derive [Checker]

  def url(_info), do: "https://www.ptscoffee.com/collections/single-origin-coffee/products/yirgacheffe-tigesit-waqa-natural"

  def headers(_info), do: nil

  def message(contents), do: "Tigesit Waqa Natural is #{contents}"

  def contents(html) do
    case Floki.parse_document html do
      {:ok, doc} -> doc
        |> Floki.find("#AddToCartText-product-template")
        |> Enum.map(&Floki.text/1)
        |> Enum.map(&String.trim/1)
      _ ->
        "error parsing"
    end
  end
end
