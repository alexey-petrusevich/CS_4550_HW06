defmodule Bulls.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      BullsWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Bulls.PubSub},
      # Start the Endpoint (http/https)
      BullsWeb.Endpoint,
      # Start a worker by calling: Bulls.Worker.start_link(arg)
      # {Bulls.Worker, arg}
      # Start BackupAgent
      FourDigits.BackupAgent,
      # Start GameSupervisor (DynamicSupervisor)
      FourDigits.GameSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    # supervisor here is different from GameSupervisor
    opts = [strategy: :one_for_one, name: Bulls.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BullsWeb.Endpoint.config_change(changed, removed)
    :ok
  end


end

# --------------------------------------------------------
# completed by using lecture notes of professor Nat Tuck
# --------------------------------------------------------