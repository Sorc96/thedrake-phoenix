defmodule Drake.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      DrakeWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Drake.PubSub},
      # Start the Endpoint (http/https)
      DrakeWeb.Endpoint,
      # Start a worker by calling: Drake.Worker.start_link(arg)
      # {Drake.Worker, arg}
      Drake.GameServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Drake.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DrakeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
