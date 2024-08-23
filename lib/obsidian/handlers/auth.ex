defmodule Obsidian.Handlers.Auth do
  import Obsidian.Util, only: [send_packet: 2, send_packet: 3]

  alias Obsidian.Context

  require Logger

  @cmsg_auth 1001

  @smsg_unknown_692 692
  @smsg_unknown_693 693
  @smsg_auth_response 1002
  @smsg_character_list 1004
  @smsg_status 1012

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

  def handle_packet(@cmsg_auth, payload, state) do
    <<_::bytes-little-size(70), ticket::bytes-little-size(38), _::bytes-little-size(26),
      mac_address::bytes-little-size(17), _rest::binary>> = payload

    with [{_, %{valid_until: _valid_until, username: username}}] <- :ets.lookup(:tickets, ticket),
         # Check valid until here.
         account when not is_nil(account) <- Context.Accounts.get_account_by_username(username) do
      Logger.debug("CMSG_AUTH: #{ticket} - #{mac_address}")

      state = state |> Map.put(:account, account)

      {bytes, _} = @unknown_bytes
      login_bytes = :binary.list_to_bin(bytes)

      send_packet(
        @smsg_auth_response,
        <<4 + length(bytes)::little-unsigned-16>> <>
          login_bytes,
        false
      )

      send_packet(
        @smsg_status,
        <<0::little-unsigned-8>>,
        false
      )

      send_packet(
        @smsg_unknown_692,
        <<50::little-unsigned-16, 60::little-unsigned-16, 70::little-unsigned-16,
          80::little-unsigned-16, 90::little-unsigned-16, 100::little-unsigned-16,
          100::little-unsigned-16>>
      )

      send_packet(
        @smsg_unknown_693,
        <<1::little-signed-integer-32>>
      )

      characters = Context.Characters.get_characters!(account)
      character_count = characters |> Enum.count()

      characters_data =
        characters
        |> Enum.map(fn c ->
          head = <<c.id::little-size(32)>> <> c.name

          current_size = byte_size(head)
          padding_size = 61 - current_size

          padding = <<0::size(padding_size * 8)>>

          frozen_at =
            case c.frozen_at do
              nil -> 0
              frozen_at_time -> Obsidian.Util.time_seconds(frozen_at_time)
            end

          head <>
            padding <>
            <<c.job::little-unsigned-8, c.gender::little-unsigned-8,
              c.hair_style::little-unsigned-8, c.hair_colour::little-unsigned-8,
              c.face_style::little-unsigned-8, 0::little-unsigned-8, c.level::little-unsigned-8,
              142::little-size(32), 0::little-unsigned-8, 0::little-size(32), 0::little-size(32),
              0::little-size(32), 0::little-size(32), frozen_at::little-size(32),
              0::little-unsigned-8>>
        end)

      packet =
        case character_count do
          0 -> <<0>>
          _ -> <<character_count::little-unsigned-8>> <> Enum.join(characters_data)
        end

      packet_length = 847 - byte_size(packet)

      send_packet(@smsg_character_list, packet <> <<0::packet_length*8>>)

      {:continue, state}
    else
      _ ->
        Logger.warning("CMSG_AUTH: Ticket expired or invalid.")
        {:close, state}
    end
  end
end
