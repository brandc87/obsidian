defmodule Obsidian.Packets.Crypt do
  import Bitwise, only: [bxor: 2]

  # Replace with your actual encryption key
  @encryption_key 129

  def encode_decode(buffer) when is_binary(buffer) do
    <<prefix::bytes-little-size(4), rest::binary>> = buffer
    updated_rest = for <<byte <- rest>>, into: <<>>, do: <<bxor(byte, @encryption_key)>>
    <<prefix::bytes-little-size(4), updated_rest::binary>>
  end
end
