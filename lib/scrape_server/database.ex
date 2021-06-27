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

  def terminate(reason, state) do
    Logger.info "shutting down database reason=#{reason}"

    case :dets.sync(state[:db]) do
      {:error, reason} -> Logger.info "error syncing database reason=#{reason}"
      :ok -> Logger.info "database synced to disk"
    end

    case :dets.close(state[:db]) do
      {:error, reason} -> Logger.info "error closing database reason=#{reason}"
      :ok -> Logger.info "database closed"
    end

    :ok
  end

  # internal api

  defp db(:init) do
    data_path = Application.get_env(:scrape_server, :data_path)

    case :dets.open_file(:"#{data_path}/url_hashes", [auto_save: 5*1000]) do
      {:ok, table} -> table
      {:error, reason} -> db(reason)
    end
  end

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

  defp urls(db) do
    Stream.resource(
      fn -> :dets.first(db) end,
      fn
        :"$end_of_table" -> {:halt, nil}
        key -> {[key], :dets.next(db, key)}
      end,
      fn _ -> :ok end
    )
  end
end
