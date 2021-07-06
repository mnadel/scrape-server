defmodule Checker.RepRings do
  @derive [Checker]

  def url(_info), do: "https://www.repfitness.com/rep-wood-gymnastic-rings"

  def message(contents), do: "Rep Rings are #{contents}"

  def contents(html) do
    lower = html |> String.downcase
    case String.contains? lower, "add to cart" do
      true -> "in stock"
      false -> "out of stock"
    end
  end
end
