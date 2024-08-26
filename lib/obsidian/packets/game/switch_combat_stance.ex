defmodule Obsidian.Packets.SwitchCombatStance do
  import Obsidian.Packets.PacketWriter

  def bytes(character, stance_id, trigger_action) do
    __MODULE__
    |> build()
    |> put_int(character.id)
    |> put_byte(stance_id)
    |> put_byte(trigger_action)
    |> Obsidian.Packets.Crypt.encode()
  end
end
