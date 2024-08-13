defmodule Obsidian.TicketGenerator do
  @random_chars ~c"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
  @prefix "ULS21-"

  def generate_ticket do
    ticket = for _ <- 1..32, into: "", do: <<Enum.random(@random_chars)>>
    @prefix <> ticket
  end
end
