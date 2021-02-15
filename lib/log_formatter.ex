defmodule LogFormatter do
  def format(level, message, timestamp, metadata) do
    "[#{timestamp}] #{level} * #{message} #{metadata[:file]}:#{metadata[:line]}\n"
  rescue
    _ -> message
  end
end
