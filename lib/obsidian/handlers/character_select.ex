defmodule Obsidian.Handlers.CharacterSelect do
  import Obsidian.Util, only: [parse_string: 1, send_packet: 2]

  alias Obsidian.Context

  require Logger

  @cmsg_create_character 1002

  @smsg_error_message 1001
  @smsg_character_created 1005

  def handle_packet(@cmsg_create_character, payload, state) do
    <<name::bytes-size(32), gender::integer-8, job::integer-8, hair_style::integer-8,
      hair_colour::integer-8, face_style::integer-8, _rest::binary>> = payload

    {:ok, character_name, _} = parse_string(name)

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

    case Context.Characters.create(state.account, attrs) do
      {:error, :character_exists} ->
        send_packet(
          @smsg_error_message,
          <<272::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
        )

      {:error, :character_limit} ->
        send_packet(
          @smsg_error_message,
          <<267::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
        )

      {:error, _} ->
        send_packet(
          @smsg_error_message,
          <<258::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
        )

      {:ok, character} ->
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

        send_packet(@smsg_character_created, character_data)
    end

    {:continue, state}
  end
end
