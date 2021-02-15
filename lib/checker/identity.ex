defmodule Checker.Identity do
  def contents(html), do: html
  def message(url, contents), do: "something at #{url} changed\n#{contents}"
end
