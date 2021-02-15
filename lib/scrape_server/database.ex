defmodule ScrapeServer.Database do
  use GenServer
  require Logger

  # client api

  def start_link(_args), do: GenServer.start_link(__MODULE__, [], name: :database)

  def check(url, data), do: GenServer.call(:database, {:check, url, data})

  def urls, do: GenServer.call(:database, :urls)

  # callbacks

  def init(_) do
    {:ok, %{db: db()}}
  end

  def handle_call({:check, url, data}, _, state) do
    {:reply, check_changed(state[:db], url, data), state}
  end

  def handle_call(:urls, _, state) do
    {:reply, urls(state[:db]), state}
  end

  # internal api

  defp check_changed(db, url, data) do
    new_hash = hash(data)
    old_hash = get(db, url)

    Logger.info "processing url=#{url}, prevhash=#{old_hash}, newhash=#{new_hash}"

    if new_hash != old_hash do
      set(db, url, new_hash)
      {:changed, true}
    else
      {:changed, false}
    end
  end

  defp hash(data) do
    hashed = :crypto.hash(:md5, data)
    hashed |> Base.encode16(case: :lower)
  end

  defp db do
    :ets.new(:url_hashes, [:set, :protected])
  end

  defp get(db, url) do
    case :ets.lookup(db, url) do
        [{_, hash}] -> hash
        _ -> nil
    end
  end

  defp set(db, url, hash) do
    Logger.info "storing url=#{url}, hash=#{hash}"
    :ets.insert(db, {url, hash})
  end

  defp urls(db) do
    Stream.resource(
      fn -> :ets.first(db) end,
      fn
        :"$end_of_table" -> {:halt, nil}
        key -> {[key], :ets.next(db, key)}
      end,
      fn _ -> :ok end
    )
  end
end
