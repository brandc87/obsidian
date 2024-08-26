defmodule Obsidian.Packets.SyncCharacter do
  import Obsidian.Packets.PacketWriter

  def bytes(character) do
    __MODULE__
    |> build()
    # Awakening experience
    |> put_int(0)
    |> put_int()
    |> put_int(character.experience)
    |> put_short()
    |> put_short()
    # Max experience
    |> put_int(100)
    |> put_int()
    # Max awakening experience
    |> put_int(2_100_000_000)
    |> put_int()
    |> put_int(character.id)
    # Map Id
    |> put_int(142)
    |> put_bytes(<<0::16*8>>)
    # Experience cap
    |> put_int()
    # Experience rate
    |> put_int(1)
    |> put_int()
    # PK Points
    |> put_int(0)
    |> put_bytes(<<0::16*8>>)
    # Current time
    |> put_int(0)
    |> put_bytes(<<0::16*8>>)
    # Luck
    |> put_short(0)
    |> put_short()
    # Position
    |> put_short(27344)
    |> put_short(14672)
    # Height
    |> put_short(1174)
    # Direction
    |> put_short()
    |> put_short()
    # Max level
    |> put_short(50)
    |> put_short()
    # Repair discount
    |> put_short(0)
    |> put_short(character.job)
    |> put_short(character.gender)
    |> put_short(character.level)
    |> put_bytes(<<0::5*8>>)
    |> put_byte()
    |> put_byte()
    |> put_byte()
    |> put_byte()
    |> put_byte()
    |> put_byte()
    |> put_bytes(<<0::29*8>>)
  end
end
