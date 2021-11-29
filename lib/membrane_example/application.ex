defmodule MembraneExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MembraneExample.Repo,
      # Start the Telemetry supervisor
      MembraneExampleWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MembraneExample.PubSub},
      # Start the Endpoint (http/https)
      MembraneExampleWeb.Endpoint
      # Start a worker by calling: MembraneExample.Worker.start_link(arg)
      # {MembraneExample.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MembraneExample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MembraneExampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
