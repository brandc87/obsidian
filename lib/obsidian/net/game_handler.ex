defmodule Obsidian.Net.GameHandler do
  use ThousandIsland.Handler

  require Logger

  alias Obsidian.Context

  @csmg_ping 23

  @cmsg_switch_stance 40

  @combat_opcodes [
    @cmsg_switch_stance
  ]

  @cmsg_chat_message 131

  @chat_opcodes [
    @cmsg_chat_message
  ]

  @cmsg_game_settings 137

  @cmsg_auth 1001

  @auth_opcodes [
    @cmsg_auth
  ]

  @cmsg_enter_map 642

  @cmsg_create_character 1002
  @cmsg_freeze_character 1003
  @cmsg_delete_character 1004
  @cmsg_unfreeze_character 1005

  @character_select_opcodes [
    @cmsg_create_character,
    @cmsg_freeze_character,
    @cmsg_delete_character,
    @cmsg_unfreeze_character
  ]

  @cmsg_enter_game 1006
  @cmsg_gateway_ping 1007

  @smsg_sync_inventory_sizes 15
  @smsg_pong 45

  @smsg_error_message 1001
  @smsg_enter_game_success 1003

  @smsg_gateway_pong 1010

  @unknown_187 187
  @unknown_266 266
  @unknown_267 267
  @unknown_272 272

  @unknown_opcodes [
    @unknown_187,
    @unknown_266,
    @unknown_267,
    @unknown_272
  ]

  @skip_decoding [
    @cmsg_auth,
    @unknown_272
  ]

  def dispatch_packet(opcode, payload, state) when opcode in @auth_opcodes do
    Obsidian.Handlers.Auth.handle_packet(opcode, payload, state)
  end

  def dispatch_packet(opcode, payload, state) when opcode in @character_select_opcodes do
    Obsidian.Handlers.CharacterSelect.handle_packet(opcode, payload, state)
  end

  def dispatch_packet(opcode, payload, state) when opcode in @chat_opcodes do
    Obsidian.Handlers.Chat.handle_packet(opcode, payload, state)
  end

  def dispatch_packet(opcode, payload, state) when opcode in @combat_opcodes do
    Obsidian.Handlers.Combat.handle_packet(opcode, payload, state)
  end

  def dispatch_packet(opcode, payload, state) when opcode in @unknown_opcodes do
    Logger.debug(
      "UNKNOWN PACKET: #{inspect(opcode, base: :hex)} (#{inspect(opcode)}) - #{inspect(payload)}"
    )

    {:continue, state}
  end

  def dispatch_packet(opcode, payload, state) do
    Logger.warning(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode)}) - #{inspect(payload)}"
    )

    {:continue, state}
  end

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
        <<@cmsg_enter_game::little-unsigned-16, packet::binary>>,
        socket,
        state
      ) do
    decoded =
      packet
      |> Obsidian.Packets.Crypt.decode()

    <<character_id::little-unsigned-32>> = decoded

    case Context.Characters.get(state.account, character_id) do
      {:ok, character} ->
        state = state |> Map.put(:character, character)
        Logger.info("CHARACTER: #{character.name} started the game.")

        Obsidian.Util.send_packet(@smsg_enter_game_success, <<character.id::little-unsigned-32>>)

        Obsidian.Util.send_packet(
          Obsidian.Packets.SyncCharacter.bytes(character)
          |> Obsidian.Packets.Crypt.encode()
        )

        Logger.info(
          "Sending: #{inspect(Obsidian.Packets.SyncCharacter.bytes(character), base: :hex, limit: :infinity)}"
        )

        Obsidian.Util.send_packet(
          @smsg_sync_inventory_sizes,
          <<
            # Equipment?
            0::little-size(16),
            # Inventory
            42::little-size(16),
            # Storage
            32::little-size(16),
            # Unknown
            0::little-size(16),
            # Unknown
            0::little-size(16),
            # Unknown
            0::little-size(16),
            # Unknown
            0::little-size(16),
            # Materials
            10::little-size(16),
            # Unknown
            0::little-size(16)
          >>
        )

        {:continue, state}

      {:error, _} ->
        reply =
          <<@smsg_error_message, 284::little-unsigned-32, 0::little-unsigned-32,
            0::little-unsigned-32>>
          |> Obsidian.Packets.Crypt.encode()

        ThousandIsland.Socket.send(socket, reply)

        {:continue, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_gateway_ping::little-unsigned-16, packet::binary>>,
        _socket,
        state
      ) do
    decoded =
      packet
      |> Obsidian.Packets.Crypt.decode()

    <<latency::little-size(32), _unknown::binary>> = decoded

    Obsidian.Util.send_packet(
      @smsg_gateway_pong,
      <<latency::little-size(32), 24174::little-size(32), 7::little-size(32)>>
    )

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@csmg_ping::little-unsigned-16, packet::binary>>,
        _socket,
        state
      ) do
    decoded =
      packet
      |> Obsidian.Packets.Crypt.decode()

    <<latency::little-size(32)>> = decoded

    Obsidian.Util.send_packet(
      @smsg_pong,
      <<latency::little-size(32)>>
    )

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_game_settings::little-unsigned-16, packet::binary>>,
        _socket,
        state
      ) do
    _decoded =
      packet
      |> Obsidian.Packets.Crypt.decode()

    # TODO: Save game settings.

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_enter_map::little-unsigned-16, _packet::binary>>,
        _socket,
        state
      ) do
    Obsidian.Util.send_packet(Obsidian.Packets.ObjectStop.bytes(state.character))
    Obsidian.Util.send_packet(Obsidian.Packets.EnterScene.bytes(state.character))

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(data, _socket, state) do
    <<opcode::little-unsigned-16, packet::binary>> = data
    Logger.debug("RECEIVED: #{inspect(opcode, base: :hex)} (#{inspect(opcode)})")

    decoded_packet =
      cond do
        opcode in @skip_decoding ->
          packet

        true ->
          packet |> Obsidian.Packets.Crypt.decode()
      end

    dispatch_packet(opcode, decoded_packet, state)
  end

  @impl GenServer
  def handle_cast({:send_packet, opcode, payload}, {socket, state}) do
    packet =
      (<<opcode::little-unsigned-16>> <> payload)
      |> Obsidian.Packets.Crypt.encode()

    ThousandIsland.Socket.send(socket, packet)

    {:noreply, {socket, state}, socket.read_timeout}
  end

  @impl GenServer
  def handle_cast({:send_unencrypted_packet, opcode, payload}, {socket, state}) do
    packet = <<opcode::little-unsigned-16>> <> payload

    ThousandIsland.Socket.send(socket, packet)

    {:noreply, {socket, state}, socket.read_timeout}
  end

  @impl GenServer
  def handle_cast({:send_packet, payload}, {socket, state}) do
    ThousandIsland.Socket.send(socket, payload)

    {:noreply, {socket, state}, socket.read_timeout}
  end
end
