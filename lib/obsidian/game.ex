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

    case :ets.lookup(:tickets, ticket) do
      [{_, ticket_data}] ->
        if DateTime.utc_now() < ticket_data.valid_until do
          Logger.info("GAME LOGIN: Ticket valid.")

          {:continue, state}
        else
          Logger.info("GAME LOGIN: Ticket expired.")

          {:close, state}
        end

      _ ->
        {:close, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(<<opcode::little-unsigned-16, packet::binary>>, _socket, state) do
    Logger.error(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode)}) - #{inspect(packet)}"
    )

    {:continue, state}
  end
end
