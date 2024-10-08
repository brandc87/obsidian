defmodule Obsidian.Handlers.CharacterSelect do
  import Obsidian.Util, only: [parse_string: 1, send_packet: 2]

  alias Obsidian.Context

  require Logger

  @cmsg_create_character 1002
  @cmsg_freeze_character 1003
  @cmsg_delete_character 1004
  @cmsg_unfreeze_character 1005

  @smsg_error_message 1001
  @smsg_character_created 1005
  @smsg_character_frozen 1006
  @smsg_character_unfrozen 1007
  @smsg_character_deleted 1008

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

  def handle_packet(@cmsg_freeze_character, payload, state) do
    <<character_id::little-size(32)>> = payload
    Logger.debug("CMSG_FREEZE_CHARACTER: #{state.account.username} - #{character_id}")

    case Context.Characters.get(state.account, character_id) do
      {:ok, character} ->
        # TODO: Check if in guild
        # TODO: Check if has mentor
        # TODO: Check if 5 or more characters already frozen
        Logger.debug("CMSG_FREEZE_CHARACTER: Freezing #{character.name}")
        Context.Characters.update(character, %{frozen_at: DateTime.utc_now()})

        send_packet(@smsg_character_frozen, <<character.id::little-unsigned-32>>)

      {:error, _} ->
        send_packet(
          @smsg_error_message,
          <<277::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
        )
    end

    {:continue, state}
  end

  def handle_packet(@cmsg_delete_character, payload, state) do
    <<character_id::little-size(32)>> = payload
    Logger.debug("CMSG_DELETE_CHARACTER: #{state.account.username} - #{character_id}")

    with {:ok, character} <- Context.Characters.get(state.account, character_id),
         true <- not is_nil(character.frozen_at) do
      Logger.debug("CMSG_DELETE_CHARACTER: Deleting #{character.name}")

      cond do
        character.level >= 40 ->
          send_packet(
            @smsg_error_message,
            <<291::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
          )

        true ->
          Obsidian.Context.Characters.delete(character)

          send_packet(@smsg_character_deleted, <<character.id::little-unsigned-32>>)
      end
    else
      _ ->
        send_packet(
          @smsg_error_message,
          <<277::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
        )
    end

    {:continue, state}
  end

  def handle_packet(@cmsg_unfreeze_character, payload, state) do
    <<character_id::little-size(32)>> = payload
    Logger.debug("CMSG_UNFREEZE_CHARACTER: #{state.account.username} - #{character_id}")

    with {:ok, character} <- Context.Characters.get(state.account, character_id),
         {:limit, false} <- {:limit, Context.Characters.at_character_limit?(state.account)},
         true <- not is_nil(character.frozen_at) do
      Logger.debug("CMSG_UNFREEZE_CHARACTER: Unfreezing #{character.name}")
      Context.Characters.update(character, %{frozen_at: nil})

      send_packet(@smsg_character_unfrozen, <<character.id::little-unsigned-32>>)
    else
      _ ->
        send_packet(
          @smsg_error_message,
          <<277::little-unsigned-32, 0::little-unsigned-32, 0::little-unsigned-32>>
        )
    end

    {:continue, state}
  end
end
