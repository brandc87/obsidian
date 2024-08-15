defmodule Obsidian.Net.TicketSender do
  use GenServer

  require Logger

  @udp_options [:binary, {:active, false}, {:reuseaddr, true}]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def send_ticket(ip, port, data) do
    GenServer.cast(__MODULE__, {:send_ticket, ip, port, data})
  end

  def init(_opts) do
    {:ok, socket} = :gen_udp.open(0, @udp_options)
    {:ok, %{socket: socket}}
  end

  def handle_cast({:send_ticket, ip, port, data}, %{socket: socket} = state) do
    :ok = :gen_udp.send(socket, ip, port, data)
    {:noreply, state}
  end
end
