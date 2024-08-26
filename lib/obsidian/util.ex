defmodule Obsidian.Util do
  import Binary, only: [split_at: 2, trim_trailing: 1]

  def send_packet(opcode, payload, encrypted \\ true) do
    case encrypted do
      true ->
        GenServer.cast(self(), {:send_packet, opcode, payload})

      false ->
        GenServer.cast(self(), {:send_unencrypted_packet, opcode, payload})
    end
  end

  def send_packet(payload) do
    GenServer.cast(self(), {:send_packet, payload})
  end

  def parse_string(payload, pos \\ 1)
  def parse_string(payload, _pos) when byte_size(payload) == 0, do: {:ok, payload, <<>>}

  def parse_string(payload, pos) do
    case :binary.at(payload, pos - 1) do
      0 ->
        {string, rest} = split_at(payload, pos)
        {:ok, trim_trailing(string), rest}

      _ ->
        parse_string(payload, pos + 1)
    end
  end

  def time_seconds(date) do
    system_time = DateTime.utc_now()
    diff_seconds = DateTime.diff(date, system_time, :second)

    diff_seconds
  end
end
