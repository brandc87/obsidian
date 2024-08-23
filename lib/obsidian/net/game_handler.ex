defmodule Obsidian.Net.GameHandler do
  use ThousandIsland.Handler

  require Logger

  alias Obsidian.Context

  @csmg_ping 23

  @cmsg_chat_message 131

  @chat_opcodes [
    @cmsg_chat_message
  ]

  @cmsg_game_settings 137

  @cmsg_auth 1001

  @auth_opcodes [
    @cmsg_auth
  ]

  @cmsg_create_character 1002
  @cmsg_freeze_character 1003

  @character_select_opcodes [
    @cmsg_create_character,
    @cmsg_freeze_character
  ]

  @cmsg_enter_game 1006
  @cmsg_gateway_ping 1007

  @smsg_sync_character 12
  @smsg_pong 45

  @smsg_error_message 1001
  @smsg_enter_game_success 1003

  @smsg_gateway_pong 1010

  @unknown_272 272

  @unknown_opcodes [
    @unknown_272
  ]

  @skip_decoding [
    @cmsg_auth
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

  def dispatch_packet(opcode, payload, state) when opcode in @chat_opcodes do
    Obsidian.Handlers.Chat.handle_packet(opcode, payload, state)
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
        Logger.info("CHARACTER: #{character.name} started the game.")

        Obsidian.Util.send_packet(@smsg_enter_game_success, <<character.id::little-unsigned-32>>)

        character_information =
          <<
            # Awakening experience 4
            0::little-size(32),
            # Unknown 4
            0::little-size(32),
            # Experience 4
            character.experience::little-size(32),
            # Unknown 2
            0::little-size(16),
            # Unknown 2
            0::little-size(16),
            # Max experience 4
            100::little-size(32),
            # Unknown 4
            0::little-size(32),
            # Max awakening experience, 4
            0::little-size(32),
            # Unknown 4
            0::little-size(32),
            # Object Id, 4
            character.id::little-size(32),
            # Map Id, 4
            142::little-size(32),
            # Unknown 16
            0::16*8,
            # Experience cap 4
            0::little-size(32),
            # Experience rate 4
            1::little-size(32),
            # Unknown 4
            0::little-size(32),
            # PK Points 4
            0::little-size(32),
            # Unknown 16
            0::16*8,
            # Current time 4
            0::little-size(32),
            # Unknown 16
            0::16*8,
            # Luck 2
            0::little-size(16),
            # Unknown 2
            0::little-size(16),
            # Position 4
            300::little-size(16),
            250::little-size(16),
            # Height 2
            0::little-size(16),
            # Direction 2
            0::little-size(16),
            # Unknown 2
            0::little-size(16),
            # Max level 2
            50::little-size(16),
            # Unknown 2
            0::little-size(16),
            # Repair discount 2
            0::little-size(16),
            # Job 1
            character.job,
            # Gender 1
            character.gender,
            # Level 1
            character.level,
            # Unknown 5
            0::5*8,
            # Distance 1
            0,
            # Auto battle 1
            0,
            # Attack mode 1
            0,
            # Unknown 1
            0,
            # Unknown 1
            0,
            # Grey name 1
            0,
            # Unknown
            0::32*8
          >>

        Logger.info("Size: #{byte_size(character_information)}")
        Obsidian.Util.send_packet(@smsg_sync_character, character_information)

      {:error, _} ->
        reply =
          <<@smsg_error_message, 284::little-unsigned-32, 0::little-unsigned-32,
            0::little-unsigned-32>>
          |> Obsidian.Packets.Crypt.encode()

        ThousandIsland.Socket.send(socket, reply)
    end

    {:continue, state}
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
  def handle_data(data, _socket, state) do
    <<opcode::little-unsigned-16, packet::binary>> = data

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
end
