defmodule Obsidian.Net.GameHandler do
  use ThousandIsland.Handler

  require Logger

  alias Obsidian.Context

  @cmsg_query_object 19

  @cmsg_login 1001
  @cmsg_create_character 1002
  @cmsg_enter_game 1006
  @cmsg_ping 1007

  @smsg_sync_character 12

  @smsg_unknown_692 692
  @smsg_unknown_693 693
  @smsg_error_message 1001
  @smsg_enter_game_success 1003
  @smsg_unknown_1004 1004
  @smsg_unknown_1005 1005
  @smsg_pong 1010

  @smsg_login_success 1002
  @smsg_status 1012

  @cmsg_switch_stance 40

  @unknown_bytes Code.eval_string("""
                 [
                 51, 52, 55, 57, 56, 49, 48, 51, 48, 50, 0, 48, 50, 0, 126,
                 126, 129, 129, 145, 166, 224, 100, 102, 58, 55, 53, 58, 49, 97, 0,
                 85, 76, 83, 50, 49, 45, 99, 49, 48, 55, 100, 50, 52, 51, 55,
                 54, 48, 48, 52, 97, 98, 100, 57, 98, 48, 52, 53, 98, 53, 98,
                 53, 57, 51, 52, 101, 1, 129, 110, 94, 0, 0, 7, 0, 0, 0,
                 49, 57, 55, 48, 45, 48, 49, 45, 48, 49, 0, 120, 156, 237, 86,
                 189, 110, 19, 65, 16, 94, 159, 239, 199, 220, 217, 119, 198, 4, 34,
                 8, 130, 40, 65, 14, 34, 16, 129, 64, 65, 130, 2, 129, 34, 10,
                 58, 76, 13, 162, 224, 73, 144, 64, 84, 60, 4, 13, 45, 79, 0,
                 5, 37, 111, 65, 67, 67, 199, 3, 132, 25, 223, 247, 113, 159, 23,
                 18, 132, 20, 41, 5, 30, 105, 180, 187, 179, 243, 247, 205, 238, 206,
                 93, 8, 33, 12, 194, 225, 84, 27, 239, 131, 62, 200, 188, 178, 249,
                 134, 172, 73, 121, 63, 132, 89, 47, 132, 28, 123, 238, 63, 255, 131,
                 158, 83, 118, 192, 158, 203, 78, 26, 39, 198, 171, 198, 37, 242, 108,
                 160, 63, 4, 143, 160, 231, 251, 99, 172, 71, 208, 45, 192, 183, 129,
                 193, 245, 87, 16, 171, 192, 248, 10, 118, 119, 140, 159, 66, 230, 246,
                 142, 237, 146, 248, 112, 222, 65, 236, 2, 254, 114, 196, 29, 137, 206,
                 54, 98, 187, 252, 153, 177, 149, 34, 156, 48, 78, 161, 159, 97, 239,
                 172, 96, 62, 15, 31, 25, 124, 228, 176, 171, 5, 183, 214, 168, 20,
                 189, 60, 154, 159, 134, 141, 143, 103, 96, 83, 98, 188, 96, 227, 4,
                 113, 104, 199, 90, 167, 209, 25, 36, 98, 155, 34, 63, 175, 223, 158,
                 232, 106, 141, 221, 199, 231, 126, 23, 135, 126, 78, 97, 62, 68, 77,
                 11, 140, 142, 111, 75, 114, 168, 32, 103, 77, 115, 137, 63, 145, 185,
                 238, 179, 158, 169, 248, 25, 192, 119, 41, 178, 57, 158, 164, 197, 208,
                 7, 51, 111, 234, 174, 71, 245, 245, 177, 65, 108, 158, 131, 203, 110,
                 200, 217, 179, 78, 190, 183, 43, 54, 5, 114, 170, 36, 111, 218, 51,
                 127, 50, 239, 133, 98, 90, 149, 249, 68, 114, 172, 69, 175, 150, 125,
                 226, 44, 176, 159, 128, 93, 70, 251, 169, 220, 43, 114, 46, 186, 190,
                 190, 40, 103, 89, 66, 54, 198, 232, 58, 3, 193, 156, 68, 182, 9,
                 176, 164, 88, 55, 178, 78, 37, 79, 98, 153, 251, 201, 218, 243, 235,
                 71, 181, 39, 206, 184, 102, 28, 137, 157, 248, 39, 152, 15, 46, 119,
                 118, 220, 119, 251, 77, 241, 163, 53, 104, 228, 46, 48, 254, 11, 155,
                 175, 25, 223, 10, 139, 239, 67, 239, 35, 49, 240, 124, 53, 255, 90,
                 106, 207, 88, 122, 94, 247, 141, 175, 10, 70, 234, 250, 250, 125, 210,
                 230, 52, 20, 12, 51, 224, 187, 34, 119, 129, 239, 85, 207, 47, 190,
                 87, 46, 219, 8, 139, 249, 191, 197, 121, 234, 251, 212, 254, 177, 164,
                 255, 147, 30, 132, 197, 30, 231, 119, 225, 26, 214, 246, 164, 230, 111,
                 225, 102, 104, 239, 201, 199, 180, 213, 221, 14, 139, 61, 121, 11, 235,
                 25, 230, 46, 155, 130, 245, 14, 150, 98, 199, 183, 163, 239, 143, 125,
                 44, 255, 11, 15, 15, 144, 39, 135, 200, 139, 104, 237, 177, 222, 37,
                 221, 219, 172, 35, 155, 235, 161, 237, 5, 204, 233, 155, 96, 81, 76,
                 187, 24, 239, 25, 111, 138, 111, 253, 54, 178, 103, 104, 127, 162, 143,
                 105, 232, 122, 99, 22, 213, 130, 239, 220, 191, 9, 95, 196, 206, 105,
                 45, 116, 223, 26, 151, 123, 239, 168, 132, 217, 171, 181, 55, 205, 251,
                 164, 212, 252, 87, 31, 234, 181, 227, 155, 164, 235, 171, 21, 106, 210,
                 68, 62, 246, 35, 210, 222, 72, 217, 39, 193, 249, 53, 180, 189, 136,
                 107, 246, 183, 215, 145, 157, 143, 123, 145, 127, 63, 31, 126, 191, 30,
                 90, 142, 59, 182, 190, 187, 110, 115, 187, 148, 143, 76, 246, 163, 183,
                 88, 147, 113, 84, 35, 173, 51, 101, 43, 230, 240, 59, 112, 62, 49,
                 62, 135, 189, 176, 164, 37, 45, 233, 200, 233, 184, 254, 45, 188, 167,
                 189, 60, 166, 216, 71, 73, 236, 185, 94, 199, 199, 214, 187, 158, 135,
                 223, 191, 109, 174, 227, 61, 178, 255, 15, 126, 127, 2, 3, 35, 255,
                 75
                 ]
                 """)

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
        <<@cmsg_login::little-unsigned-16, _::bytes-little-size(70),
          ticket::bytes-little-size(38), _::bytes-little-size(26),
          mac_address::bytes-little-size(17), _rest::binary>>,
        socket,
        state
      ) do
    Logger.debug("GAME LOGIN: #{ticket} - #{mac_address}")

    with [{_, %{valid_until: _valid_until, username: username}}] <- :ets.lookup(:tickets, ticket),
         # Check valid until here.
         account when not is_nil(account) <- Context.Accounts.get_account_by_username(username) do
      state = state |> Map.put(:account, account)

      {bytes, _} = @unknown_bytes
      login_bytes = :binary.list_to_bin(bytes)

      login_success =
        <<@smsg_login_success::little-unsigned-16, 4 + length(bytes)::little-unsigned-16>> <>
          login_bytes

      ThousandIsland.Socket.send(socket, login_success)

      server_status =
        <<@smsg_status::little-unsigned-16, 0::little-unsigned-8>>

      ThousandIsland.Socket.send(socket, server_status)

      unknown_692 =
        <<@smsg_unknown_692::little-unsigned-16, 50::little-unsigned-16, 60::little-unsigned-16,
          70::little-unsigned-16, 80::little-unsigned-16, 90::little-unsigned-16,
          100::little-unsigned-16, 100::little-unsigned-16>>
        |> Obsidian.Packets.Crypt.encode()

      ThousandIsland.Socket.send(socket, unknown_692)

      unknown_693 =
        <<@smsg_unknown_693::little-unsigned-16, 1::little-signed-integer-32>>
        |> Obsidian.Packets.Crypt.encode()

      ThousandIsland.Socket.send(socket, unknown_693)

      characters = Context.Characters.get_characters!(account)
      character_count = characters |> Enum.count()

      characters_data =
        characters
        |> Enum.map(fn c ->
          head = <<c.id::little-size(32)>> <> c.name

          current_size = byte_size(head)
          padding_size = 61 - current_size

          padding = <<0::size(padding_size * 8)>>

          head <>
            padding <>
            <<c.job::little-unsigned-8, c.gender::little-unsigned-8,
              c.hair_style::little-unsigned-8, c.hair_colour::little-unsigned-8,
              c.face_style::little-unsigned-8, 0::little-unsigned-8, c.level::little-unsigned-8,
              142::little-size(32), 0::little-unsigned-8, 0::little-size(32), 0::little-size(32),
              0::little-size(32), 0::little-size(32), 0::little-size(32), 0::little-unsigned-8>>
        end)

      packet =
        case character_count do
          0 -> <<0>>
          _ -> <<character_count::little-unsigned-8>> <> Enum.join(characters_data)
        end

      packet_length = 847 - byte_size(packet)

      Obsidian.Util.send_packet(@smsg_unknown_1004, packet <> <<0::packet_length*8>>)

      # unknown_1004 =
      #  (<<@smsg_unknown_1004::little-unsigned-16>> <>
      #     packet <> <<0::packet_length*8>>)
      #  |> Obsidian.Packets.Crypt.encode()

      # ThousandIsland.Socket.send(socket, unknown_1004)

      {:continue, state}
    else
      _ ->
        Logger.warning("GAME LOGIN: Ticket expired or invalid.")
        {:close, state}
    end
  end

  @impl ThousandIsland.Handler
  def handle_data(
        <<@cmsg_create_character::little-unsigned-16, packet::binary>>,
        socket,
        state
      ) do
    decoded =
      packet
      |> Obsidian.Packets.Crypt.decode()

    <<name::bytes-size(32), gender::integer-8, job::integer-8, hair_style::integer-8,
      hair_colour::integer-8, face_style::integer-8,
      _rest::binary>> =
      decoded

    {:ok, character_name, _} = Obsidian.Util.parse_string(name)

    hair_style = job * 65536 + gender * 256 + hair_style
    face_style = job * 65536 + gender * 256 + face_style

    attrs = %{
      name: character_name,
      gender: gender,
      job: job,
      hair_style: hair_style,
      hair_colour: hair_colour,
      face_style: face_style
    }

    characters = Context.Characters.get_characters!(state.account)
    character_count = characters |> Enum.count()

    if character_count >= 4 do
      reply =
        <<@smsg_error_message, 267::little-unsigned-32, 0::little-unsigned-32,
          0::little-unsigned-32>>
        |> Obsidian.Packets.Crypt.encode()

      ThousandIsland.Socket.send(socket, reply)

      {:continue, state}
    end

    if byte_size(character_name) > 24 do
      reply =
        <<@smsg_error_message, 270::little-unsigned-32, 0::little-unsigned-32,
          0::little-unsigned-32>>
        |> Obsidian.Packets.Crypt.encode()

      ThousandIsland.Socket.send(socket, reply)

      {:continue, state}
    end

    {:ok, character} = Context.Characters.create(state.account, attrs)

    head = <<character.id::little-size(32)>> <> character.name

    current_size = byte_size(head)
    padding_size = 61 - current_size

    padding = <<0::size(padding_size * 8)>>

    character_data =
      head <>
        padding <>
        <<character.job::little-unsigned-8, character.gender::little-unsigned-8,
          character.hair_style::little-unsigned-8, character.hair_colour::little-unsigned-8,
          character.face_style::little-unsigned-8, 0::little-unsigned-8,
          character.level::little-unsigned-8, 142::little-size(32), 0::little-unsigned-8,
          0::little-size(32), 0::little-size(32), 0::little-size(32), 0::little-size(32),
          0::little-size(32), 0::little-unsigned-8>>

    unknown_1005 =
      (<<@smsg_unknown_1005::little-unsigned-16>> <> character_data)
      |> Obsidian.Packets.Crypt.encode()

    ThousandIsland.Socket.send(socket, unknown_1005)

    {:continue, state}
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
        <<@cmsg_ping::little-unsigned-16, packet::binary>>,
        _socket,
        state
      ) do
    decoded =
      packet
      |> Obsidian.Packets.Crypt.decode()

    <<latency::little-size(32), _unknown::binary>> = decoded

    Obsidian.Util.send_packet(
      @smsg_pong,
      <<latency::little-size(32), 24174::little-size(32), 7::little-size(32)>>
    )

    {:continue, state}
  end

  @impl ThousandIsland.Handler
  def handle_data(<<opcode::little-unsigned-16, packet::binary>>, _socket, state) do
    Logger.warning(
      "UNIMPLEMENTED: #{inspect(opcode, base: :hex)} (#{inspect(opcode)}) - #{inspect(packet)}"
    )

    {:continue, state}
  end

  @impl GenServer
  def handle_cast({:send_packet, opcode, payload}, {socket, state}) do
    packet =
      (<<opcode::little-unsigned-16>> <> payload)
      |> Obsidian.Packets.Crypt.encode()

    ThousandIsland.Socket.send(socket, packet)

    {:noreply, {socket, state}, socket.read_timeout}
  end
end
