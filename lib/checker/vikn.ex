defmodule Checker.Vikn do
  @derive [Checker]

  def url(_info), do: "https://viknperformance.com/collections/liquid-chalk-vikn-performance/products/liquid-chalk"

  def contents(html) do
    case Floki.parse_document html do
      {:ok, doc} -> doc
        |> Floki.find("#AddToCart-1515994021941 span")
        |> Enum.map(&Floki.text/1)
        |> Enum.map(&String.trim/1)
      _ ->
        "error parsing"
    end
  end

  def message(contents), do: "Liquid chalk is #{contents}"
end
