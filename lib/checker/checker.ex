defprotocol Checker do
  @spec url(String.t()) :: String.t()
  @doc "return the url that this checker is checking"
  def url(_info)

  @spec contents(String.t()) :: String.t()
  @doc "given the html source, generate the interesting contents of the page"
  def contents(html)

  @spec message(String.t()) :: String.t()
  @doc "given the above contents, generate the text of the notification message"
  def message(contents)
end
