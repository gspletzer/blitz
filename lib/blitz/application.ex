defmodule Blitz.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BlitzWeb.Telemetry,
      # Start the Ecto repository
      Blitz.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Blitz.PubSub},
      # Start Finch
      {Finch, name: Blitz.Finch},
      # Start the Endpoint (http/https)
      BlitzWeb.Endpoint
      # Start a worker by calling: Blitz.Worker.start_link(arg)
      # {Blitz.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blitz.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlitzWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
