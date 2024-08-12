defmodule Obsidian.Auth do
  use ThousandIsland.Handler

  require Logger

  @cmd_auth_login 1280
  @cmd_auth_create_account 1282

  @impl ThousandIsland.Handler
  def handle_connection(_socket, state) do
    Logger.info("CLIENT CONNECTED")

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_close(_socket, _state) do
    Logger.info("CLIENT DISCONNECTED")
  end

  @impl ThousandIsland.Handler
  def handle_data(<<@cmd_auth_login::little-unsigned-16, packet::binary>>, _socket, state) do
    array =
      packet
      |> :binary.bin_to_list()
      |> to_string()
      |> String.split("/")

    if length(array) == 2 do
      [username, password] = array
      Logger.info("CLIENT LOGIN: #{username} - #{password}")
    end

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmd_auth_create_account::little-unsigned-16, packet::binary>>,
        _socket,
        _state
      ) do
    data =
      packet
      |> :binary.bin_to_list()
      |> to_string()
      |> String.split("/")

    if length(data) == 5 do
      [username, password, question, answer, referrer_code] = data
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(<<opcode::little-unsigned-16, packet::binary>>, _socket, state) do
    Logger.error(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode, base: :hex)}) - #{inspect(packet)}"
    )

    {:continue, state}
  end
end
