defmodule Obsidian.Packets.EnterScene do
  import Obsidian.Packets.PacketWriter

  def bytes(_character) do
    __MODULE__
    |> build()
    |> put_int(142)
    |> put_int(1)
    |> put_byte()
    |> put_short(300)
    |> put_short(250)
    # Height
    |> put_short()
    |> Obsidian.Packets.Crypt.encode()
  end
end
