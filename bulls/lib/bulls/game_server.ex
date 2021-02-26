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
  # to retrieve info from the registry
  def reg(gameName) do
    {:via, Registry, {FourDigits.GameReg, gameName}}
  end

  # starts the game given the name of the game
  def start(gameName) do
    spec = %{
      id: __MODULE__, # name of the child
      start: {__MODULE__, :start_link, [gameName]},
      restart: :permanent,
      type: :worker
    }
    # here child represents a new game
    # returns {:ok, pid}
    # spec is the list of parameters for starting child process
    FourDigits.GameSupervisor.start_child(spec)
  end

  # starts this process (GenServer)
  def start_link(gameName) do
    # check if the game has been saved in the backup agent
    # the backup agent has already been started by the main thread
    # BackupAgent is shared between all the games
    game = BackupAgent.get(gameName) || Game.new
    # start the server with the game state
    # if the server has failed somehow, it will restart
    # with the game retrieved from the BackupAgent
    GenServer.start_link(
      __MODULE__,
      # module name
      game,
      # any, which is state here
      name: reg(gameName)
      # options
    )
  end

  # this is client side functions
  # reg(name) returns PID

  # resets the game state
  # here reg(name) gets the game from the registry
  # this is a wrapper method for GenServer.call -> :reset
  # actual listener is below
  def reset(gameName) do
    GenServer.call(reg(gameName), {:reset, gameName})
  end

  # makes a new guess given game name, player name, and a guess
  # this is a wrapper method for GenServer.call -> :makeGuess
  # actual listener is below
  def makeGuess(gameName, playerName, newGuess) do
    GenServer.call(reg(gameName), {:makeGuess, gameName, playerName, newGuess})
  end


  # returns the state of the game given the name of the game
  # this is a wrapper method for GenServer.call -> :peek
  # actual listener is below
  def peek(gameName) do
    GenServer.call(reg(gameName), {:peek, gameName})
  end

  # star_link calls this method with gameState
  def init(game) do
    # TODO: do we need this :pook here?
    # calls :pook every 10 seconds?
    #Process.send_after(self(), :pook, 30_000)
    {:ok, game} # this is returned if start_link was successful
  end

  # here game is retrieved from the registry
  # from is info about the caller
  # game -> state of the game
  def handle_call({:reset, gameName}, _from, game) do
    # create new game
    game = Game.new
    # BackupAgent has already been started by this point
    # replace the game in the backup agent
    BackupAgent.put(gameName, game)
    # send a reply back to the caller with the new game state
    {:reply, game, game}
  end

  # handles guess calls from GenServer.call
  def handle_call({:makeGuess, gameName, playerName, newGuess}, _from, game) do
    # modifies the game with the new guess
    game = Game.makeGuess(game, playerName, newGuess)
    # put modified game into the backup agent
    BackupAgent.put(gameName, game)
    # reply to the caller with updated game state
    {:reply, game, game}
  end

  # simply returns the state of the game at any moment
  # for the callers
  def handle_call({:peek, gameName}, _from, gameState) do
    # get the game state from the backup agent
    game = BackupAgent.get(gameName)
    # return the game state to the caller
    {:reply, game, game}
  end

  # this is used to broadcast to everyone on the channel the state of the game
  # TODO: for every turn a player has not submitted a guess, add an empty string (pass)
  # TODO to the list of guesses of that specific player
  # TODO: if the game is won, reset the game, and change the state from gameOver
  # TODO: modify the game such that the guesses are not being sent back until this function is being called
  def handle_info(:pook, game) do
    # TODO ???
    #    game = Game.guess(game, "q")
    BullsWeb.Endpoint.broadcast!(
      "game:1",
      # FIXME: Game name should be in state
      "view",
      Game.view(game)
    )
    {:noreply, game}
  end
end
