defmodule Obsidian.Packets.ObjectStop do
  import Obsidian.Packets.PacketWriter

  def bytes(character) do
    __MODULE__
    |> build()
    |> put_int(character.id)
    |> put_byte()
    |> put_short(300)
    |> put_short(250)
    # Height
    |> put_short()
    |> Obsidian.Packets.Crypt.encode()
  end
end
