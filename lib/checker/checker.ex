defprotocol Checker do
  @spec contents(String.t()) :: String.t()
  @doc "given a html source, generate the interesting contents of the page"
  def contents(html)

  @spec message(String.t(), String.t()) :: String.t()
  @doc "given the above contents and url, generate a the text of a notification message"
  def message(url, contents)
end
