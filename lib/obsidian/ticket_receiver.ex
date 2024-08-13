defmodule Obsidian.TicketReceiver do
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

    {:noreply, state}
  end

  def terminate(_reason, %{socket: socket}) do
    :gen_udp.close(socket)
    :ok
  end
end
