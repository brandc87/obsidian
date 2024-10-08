defmodule Obsidian.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @handler_options %{
    backlog: 1024,
    nodelay: true,
    send_timeout: 30_000,
    send_timeout_close: true,
    reuseaddr: true
  }

  @auth_port 7800
  @game_port 8701

  @impl true
  def start(_type, _args) do
    children = [
      ObsidianWeb.Telemetry,
      Obsidian.Repo,
      {DNSCluster, query: Application.get_env(:obsidian, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Obsidian.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Obsidian.Finch},
      # Start a worker by calling: Obsidian.Worker.start_link(arg)
      # {Obsidian.Worker, arg},
      {Obsidian.Net.TicketReceiver, [name: Obsidian.Net.TicketReceiver]},
      {Obsidian.Net.TicketSender, [name: Obsidian.Net.TicketSender]},
      {ThousandIsland,
       port: @auth_port,
       handler_module: Obsidian.Net.AuthHandler,
       handler_options: @handler_options},
      {ThousandIsland,
       port: @game_port,
       handler_module: Obsidian.Net.GameHandler,
       handler_options: @handler_options},
      # Start to serve requests, typically the last entry
      ObsidianWeb.Endpoint
    ]

    :ets.new(:tickets, [:named_table, :public])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Obsidian.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ObsidianWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
