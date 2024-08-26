defmodule Obsidian.Packets do
  @send_ops %{
    12 => "SYNC_CHARACTER",
    39 => "ENTER_SCENE",
    48 => "OBJECT_STOP",
    105 => "SWITCH_COMBAT_STANCE"
  }

  def name_to_opcode(name) do
    case Enum.find(@send_ops, fn {_k, v} -> name == v end) do
      {opcode, _name} -> opcode
      _ -> nil
    end
  end
end
