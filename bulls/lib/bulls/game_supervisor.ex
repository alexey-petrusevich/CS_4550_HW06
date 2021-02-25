defmodule FourDigits.GameSupervisor do
  use DynamicSupervisor

  # starts this dynamic supervisor
  # represents a wrapper function around DynamicSupervisor.start_link/1
  def start_link(arg) do
    # this returns {:ok, pid} on success
    DynamicSupervisor.start_link(
      __MODULE__,
      arg,
      name: __MODULE__
    )
  end

  # init is automatically invoked by start_link/1
  # represents a wrapper functions around DynamicSupervisor.init/1
  @impl true
  def init(_arg) do
    # start new registry when this dynamic supervisor is started
    # the registry is used for storing PIDs with unique keys
    {:ok, _} = Registry.start_link(
      keys: :unique,
      name: FourDigits.GameReg,
    )
    # this call returns {:ok, state} on success
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  # starts a new child given child specifications
  # return format {:ok, child}
  # represents a wrapper of DynamicSupervisor.start_child/1
  def start_child(spec) do
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end
