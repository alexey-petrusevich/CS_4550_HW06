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
    game = BackupAgent.get(gameName) || Game.new(gameName)
    BackupAgent.put(gameName, game)
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


  # makes a call to ready
  def toggleReady(gameName, playerName) do
    IO.inspect("calling GenServer :ready")
    GenServer.call(reg(gameName), {:ready, gameName, playerName})
  end


  # returns the state of the game given the name of the game
  # this is a wrapper method for GenServer.call -> :peek
  # actual listener is below
  def peek(gameName) do
    GenServer.call(reg(gameName), {:peek, gameName})
  end


  # star_link calls this method with gameState
  def init(game) do
    # calls :pook every 30 seconds
    # :pook will append any guesses and check for the winners
    Process.send_after(self(), :pook, 30_000)
    {:ok, game} # this is returned if start_link was successful
  end


  # here game is retrieved from the registry
  # from is info about the caller
  # game -> state of the game
  def handle_call({:reset, gameName}, _from, gameState) do
    # create new game
    game = Game.new(gameName)
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


  # handles reset call from GenServer.call
  def handle_call({:ready, gameName, playerName}, _from, gameState) do
    IO.inspect("callning Game.toggleReady()")
    game = Game.toggleReady(gameState, playerName)
    BackupAgent.put(gameName, game)
    {:reply, game, game}
  end


  # simply returns the state of the game at any moment
  # for the callers
  def handle_call({:peek, gameName}, _from, gameState) do

    # get the game state from the backup agent
    game = BackupAgent.get(gameName)

    IO.inspect("PEEK :> game taken from backup agent: ")
    IO.inspect(game)
    # return the game state to the caller
    {:reply, game, game}
  end


  # this is used to broadcast to everyone on the channel the state of the game
  # handles pook calls (every 30 seconds by default)
  def handle_info(:pook, gameState) do
    if (Game.isGameInProgress(gameState)) do
      # make all guesses - take current guesses and put them into player's guesses
      # this also updates hints
      newState = Game.makeAllGuesses(gameState)
      # clear current guesses
      newState = Game.clearCurrentGuesses(newState)
      # check if the game has been won
      newState = Game.checkWinners(newState)
      BullsWeb.Endpoint.broadcast!(
        "game:" <> newState.gameName,
        "view",
        Game.view(newState)
      )
      {:noreply, newState}
    else
      {:noreply, gameState}
    end
  end
end
