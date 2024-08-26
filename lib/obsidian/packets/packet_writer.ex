defmodule Obsidian.Packets.PacketWriter do
  def build(module) do
    name =
      module
      |> to_string()
      |> String.split(".")
      |> List.last()
      |> Macro.underscore()
      |> String.upcase()

    opcode = Obsidian.Packets.name_to_opcode(name)
    put_short(<<>>, opcode)
  end

  def put_bool(packet, true), do: packet <> <<1>>
  def put_bool(packet, false), do: packet <> <<0>>
  def put_byte(packet, byte \\ 0x0), do: packet <> <<byte>>
  def put_bytes(packet, b), do: packet <> <<b::bytes>>

  def put_int(packet, int \\ 0x0)
  def put_int(packet, nil), do: put_int(packet)
  def put_int(packet, int), do: packet <> <<int::little-unsigned-integer-32>>

  def put_long(packet, int \\ 0x0)
  def put_long(packet, nil), do: put_long(packet)
  def put_long(packet, int), do: packet <> <<int::little-unsigned-integer-64>>

  def put_short(packet, short \\ 0x0), do: packet <> <<short::little-unsigned-integer-16>>
end
