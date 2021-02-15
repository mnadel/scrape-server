defmodule ScrapeServer.Database do
  use GenServer
  require Logger

  # client api

  def start_link(_args), do: GenServer.start_link(__MODULE__, [], name: :database)

  def check(url, data), do: GenServer.call(:database, {:check, url, data})

  # callbacks

  def init(_) do
    {:ok, %{db: db(:init)}}
  end

  def handle_call({:check, url, data}, _, state) do
    {:reply, check_changed(state[:db], url, data), state}
  end

  # internal api

  defp check_changed(db, url, data) do
    new_hash = hash(data)
    old_hash = get(db, url)

    Logger.info "url=#{url}, prevhash=#{old_hash}, newhash=#{new_hash}"

    case hashes_differ(new_hash, old_hash) do
      true ->
        set(db, url, new_hash)
        {:changed, true}
      false ->
        {:changed, false}
    end
  end

  defp hashes_differ(a, b) when a == b, do: false
  defp hashes_differ(a, b) when a != b, do: true

  defp hash(data) do
    hashed = :crypto.hash(:md5, data)
    hashed |> Base.encode16(case: :lower)
  end

  defp db(:init) do
    case :dets.open_file(:url_hashes, [auto_save: 5*1000]) do
      {:ok, table} -> table
      {:error, reason} -> db(reason)
    end
  end

  defp db(reason) do
    Logger.error "repairing db reason=#{reason}"
    {:ok, table} = :dets.open_file(:url_hashes, [auto_save: 5*1000, repair: true])
    table
  end

  defp get(db, url) do
    case :dets.lookup(db, url) do
        [{_, hash}] -> hash
        _ -> nil
    end
  end

  defp set(db, url, hash) do
    Logger.info "storing url=#{url}, hash=#{hash}"
    :dets.insert(db, {url, hash})
  end
end
