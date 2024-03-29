defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias FourDigits.Game
  alias FourDigits.GameServer


  # this method is called when a new channel is created
  @impl true
  def join("game:" <> gameName, payload, socket) do
    # start game server (a.k.a. initialize new game when joined)
    # this would not start a duplicate server - all the keys in corresponding
    # Registry are unique
    GameServer.start(gameName)
    # create new socket, and store game name in the socket
    socket = socket
             |> assign(:gameName, gameName)
    # get state of the game from the server (process)
    # here the game should be fresh - no guesses made
    # or the current game game
    gameState = GameServer.peek(gameName)
    # truncate any secret info and reveal only what is necessary
    # to the caller
    view = Game.view(gameState)
    # return view back to the caller
    {:ok, view, socket}
  end


  @impl true
  def handle_in("login", _, socket) do
    # retrieve name of the game from the socket
    gameName = socket.assigns[:gameName]
    getGameView(gameName, socket)
  end


  @impl true
  def handle_in(
        "join_as_observer",
        %{"observerName" => observerName},
        socket
      ) do
    gameState = socket.assigns[:gameName]
                |> GameServer.peek()
    # add to the list of observers
    gameState = Game.updateObserver(gameState, observerName)
    FourDigits.BackupAgent.put(gameState.gameName, gameState)
    view = Game.view(gameState)
    {:reply, {:ok, view}, socket}
  end


  # simply returns a game view stored in the socket and the game server
  def getGameView(gameName, socket) do
    view = socket.assigns[:gameName]
           |> GameServer.peek()
           |> Game.view()
    {:reply, {:ok, view}, socket}
  end


  @impl true
  def handle_in(
        "join_as_player",
        %{"playerName" => playerName},
        socket
      ) do

    # retrieve game from the game server
    gameState = socket.assigns[:gameName]
                |> GameServer.peek()
    # if the game is still in set up mode, join the game as player
    if (Game.isGameInSetUp(gameState)) do
      # update the game with new player
      gameState = Game.updateJoin(gameState, playerName)
      FourDigits.BackupAgent.put(gameState.gameName, gameState)
      # truncate any sensitive info
      view = Game.view(gameState)
      {:reply, {:ok, view}, socket}
    else
      # else game is full, in progress, or game over
      view = Game.view(gameState)
      # return view back to the caller
      {:reply, {:ok, view}, socket}
    end
  end


  # given playerName, gameName, and newGuess, updates the state
  # of the game and returns new state
  @impl true
  def handle_in(
        "guess",
        %{
          "guess" => newGuess,
          "playerName" => playerName
        },
        socket
      ) do
    # retrieve game from the game server
    gameName = socket.assigns[:gameName]
    gameState = GameServer.peek(gameName)
    # check if the game in progress
    if (Game.isGameInProgress(gameState)) do
      view = GameServer.makeGuess(gameName, playerName, newGuess)
             # truncate state to what is viewed by the player (everyone?)
             |> Game.view()
      # broadcast the view to everyone connected to the socket
      broadcast(socket, "view", view)
      # send a reply with the view to the caller
      {:reply, {:ok, view}, socket}
    else
      # else game is not in progress - no guessing allowed
      # simply return the game state
      view = Game.view(gameState)
      # broadcast the view to everyone connected to the socket
      broadcast(socket, "view", view)
      # send a reply with the view to the caller
      {:reply, {:ok, view}, socket}
    end
  end


  @impl true
  def handle_in("ready", %{"playerName" => playerName}, socket) do
    # retrieve game state from the game server
    gameState = socket.assigns[:gameName]
                |> GameServer.peek()
    # if game is full or in set up state, find the player and mark him ready
    if (Game.isGameFull(gameState)
        || Game.isGameInSetUp(gameState)) do
      # retrieve saved game name from the socket
      # and mark it as ready

      view = socket.assigns[:gameName]
             |> GameServer.toggleReady(playerName)
             |> Game.view()
      # broadcast the view to everyone connected to the socket
      broadcast(socket, "view", view)
      # send a reply with the view to the caller
      {:reply, {:ok, view}, socket}
    else
      # game is not is setUp or gameFull state - do nothing
      view = gameState
             |> Game.view()
      # broadcast the view to everyone connected to the socket
      broadcast(socket, "view", view)
      # send a reply with the view to the caller
      {:reply, {:ok, view}, socket}
    end
  end




  @impl true
  def handle_in("start", %{"gameName" => gameName}, socket) do
    gameState = socket.assigns[:gameName]
                |> GameServer.peek()
    view = socket.assigns[:gameName]
           |> GameServer.startGame()
           |> Game.view()
    broadcast(socket, "view", view)
    {:reply, {:ok, view}, socket}
  end




  # this endpoint listens to "reset" messages
  @impl true
  def handle_in("reset", _, socket) do
    #    user = socket.assigns[:user]
    view = socket.assigns[:gameName] # get name of the game and pass it to the reset
           # game server will use the saved name to find the name in the Registry
           |> GameServer.reset(
              ) # reset the game and get fresh game state
           |> Game.view(
              ) # truncate all secrets by passing fresh state to the view() method
    # broadcast new view to everyone connected to this socket
    broadcast(socket, "view", view)
    # send a reply back to the caller
    {:reply, {:ok, view}, socket}
  end


  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end


  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  @impl true
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end

# --------------------------------------------------------
# completed by using lecture notes of professor Nat Tuck
# --------------------------------------------------------