defmodule Obsidian.Handlers.Chat do
  require Logger

  @cmsg_chat_message 131

  def handle_packet(@cmsg_chat_message, _payload, _state) do
  end
end
