# represents a new game of bulls and cows
# also represents a process to be added to the DynamicSupervisor
defmodule FourDigits.GameServer do
  use GenServer

  alias FourDigits.BackupAgent
  alias FourDigits.Game

  # Adds new entry into the registry or returns existing entry.
  # Registry here automatically started by DynamicSupervisor (GameSupervisor)
  # return format {:via, Registry, {FourDigits.GameReg, gameName}}
  # this tuple is then used by GenServer.call/2 instead of PID
  def reg(name) do
    {:via, Registry, {FourDigits.GameReg, name}}
  end

  # starts the game given the name of the game
  def start(name) do
    spec = %{
      id: __MODULE__, # name of the child
      start: {__MODULE__, :start_link, [name]},
      restart: :permanent,
      type: :worker
    }
    # here child represents a new game
    # returns {:ok, pid}
    # spec is the list of parameters for starting child process
    FourDigits.GameSupervisor.start_child(spec)
  end

  # starts this process (GenServer)
  def start_link(name) do
    game = BackupAgent.get(name) || Game.new
    GenServer.start_link(
      __MODULE__, # module name
      game, # any, which is state here
      name: reg(name) # options
    )
  end

  # this is client side functions
  # reg(name) returns PID

  # resets the game state
  # here reg(name) gets the game from the registry
  def reset(gameName) do
    GenServer.call(reg(gameName), {:reset, gameName})
  end

  # makes a new guess given game name, player name, and a guess
  def guess(gameName, playerName, newGuess) do
    GenServer.call(reg(gameName), {:guess, gameName, playerName, newGuess})
  end

  # TODO may not need this
  # returns the state of the game given the name of the game
  #
  def peek(gameName) do
    GenServer.call(reg(gameName), {:peek, gameName})
  end

  # implementation

  def init(game) do
    #Process.send_after(self(), :pook, 10_000)
    {:ok, game}
  end

  # here game is retrieved from the registry
  # from is info about the caller
  # game -> state of the game
  def handle_call({:reset, gameName}, _from, game) do
    game = Game.new
    # BackupAgent has already been started by this point
    BackupAgent.put(gameName, game)
    {:reply, game, game}
  end

  # handles guess calls from GenServer.call
  def handle_call({:guess, gameName, playerName, newGuess}, _from, game) do
    # modifies the game with the new guess
    game = Game.guess(game, playerName, newGuess)
    # put modified game into the backup agent
    BackupAgent.put(gameName, game)
    # reply to the caller with updated game state
    {:reply, game, game}
  end

  # simply returns the state of the game at any moment
  # for the callers
  def handle_call({:peek, gameName}, _from, gameState) do
    game = BackupAgent.get(gameName)
    {:reply, game, game}
  end

  # this is used to broadcast to everyone on the channel the state of the game
  def handle_info(:pook, game) do
    # TODO ???
#    game = Game.guess(game, "q")
    BullsWeb.Endpoint.broadcast!(
      "game:1", # FIXME: Game name should be in state
      "view",
      Game.view(game, ""))
    {:noreply, game}
  end
end
