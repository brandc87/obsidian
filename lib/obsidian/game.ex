defmodule Obsidian.Game do
  use ThousandIsland.Handler

  require Logger

  @cmsg_game_login 1001

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
  def handle_data(
        <<@cmsg_game_login::little-unsigned-16, _::bytes-little-size(70),
          ticket::bytes-little-size(38), _::bytes-little-size(26),
          mac_address::bytes-little-size(17), _rest::binary>>,
        _socket,
        state
      ) do
    Logger.info("GAME LOGIN: #{ticket} - #{mac_address}")

    [{_, ticket_data}] = :ets.lookup(:tickets, ticket)

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(<<opcode::little-unsigned-16, packet::binary>>, _socket, state) do
    Logger.error(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode)}) - #{inspect(packet)}"
    )

    {:continue, state}
  end
end
