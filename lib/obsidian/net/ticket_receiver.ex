defmodule Obsidian.Net.TicketReceiver do
  use GenServer

  require Logger

  @udp_options [:binary, {:active, true}, {:reuseaddr, true}]
  @port 6678

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(@port, @udp_options)
    {:ok, %{socket: socket}}
  end

  def handle_info({:udp, _socket, ip, port, message}, state) do
    Logger.info("Received packet from #{inspect(ip)}:#{port} - #{message}")

    data =
      message
      |> String.split(";")

    if length(data) >= 4 do
      [ticket, username, promo_code, referrer_code, uuid] = data

      valid_until =
        DateTime.utc_now()
        |> DateTime.add(5 * 60, :second)

      data = %{
        ticket: ticket,
        username: username,
        promo_code: promo_code,
        referrer_code: referrer_code,
        uuid: uuid,
        valid_until: valid_until
      }

      :ets.insert(:tickets, {ticket, data})
    end

    {:noreply, state}
  end

  def terminate(_reason, %{socket: socket}) do
    :gen_udp.close(socket)
    :ok
  end
end
