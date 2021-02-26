defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias FourDigits.Game
  alias FourDigits.GameServer

  # this method is called when a new game is created
  @impl true
  def join("game:" <> gameName, %{"playerName" => playerName}, socket) do
    # start game server (a.k.a. initialize new game when joined)
    # this would not start a duplicate server - all the keys in corresponding
    # Registry are unique
    GameServer.start(gameName)
    # create new socket, and store game name in the socket
    socket = socket
             # store name of the game in the socket
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
  def handle_in("login", %{"gameName" => gameName}) do
    view = socket.assigns[:gameName]
           |> GameServer.peek()
           |> Game.view()
    {:reply, {:ok, view}, socket}
  end

  @impl true
  def handle_in("join_as_observer", %{"gameName" => gameName}) do
    view = socket.assigns[:gameName]
           |> GameServer.peek()
           |> Game.view()
    {:reply, {:ok, view}, socket}
  end

  @impl true
  def handle_in("join_as_player", %{"playerName" => playerName, "gameName" => gameName}) do
    # TODO implement
    # update the game with new user and change the state if necessary
    # this also covers the case when the game is in :playing state
    if (!Game.isGameFull(gameState)) do
      # update the game with new player
      gameState = Game.updateJoin(gameState, playerName)

    else
      # else game is full, just return view
      # truncate any secret info and reveal only what is necessary
      # to the caller
      view = Game.view(gameState)
      # return view back to the caller
      {:ok, view, socket}
    end
  end


  # given playerName, gameName, and newGuess, updates the state
  # of the game and returns new state
  @impl true
  def handle_in(
        "guess",
        %{
          "playerName" => playerName,
          "guess" => newGuess
        },
        socket
      ) do

    # retrieve saved game name from the socket
    view = socket.assigns[:gameName]
           # make a new guess given playerName and newGuess
           |> GameServer.makeGuess(playerName, newGuess)
      # truncate state to what is viewed by the player (everyone?)
           |> Game.view()
    # broadcast the view to everyone connected to the socket
    broadcast(socket, "view", view)
    # send a reply with the view to the caller
    {:reply, {:ok, view}, socket}
  end


  def handle_in("ready", %{"playerName" => playerName}, socket) do
    # retrieve saved game name from the socket
    # and mark it as ready
    view = socket.assigns[:gameName]
           |> GameServer.toggleReady(playerName)
           |> Game.view()
    # broadcast the view to everyone connected to the socket
    broadcast(socket, "view", view)
    # send a reply with the view to the caller
    {:reply, {:ok, view}, socket}
  end


  # this endpoint listens to "reset" messages
  @impl true
  def handle_in("reset", _, socket) do
    #    user = socket.assigns[:user]
    view = socket.assigns[:gameName] # get name of the game and pass it to the reset
           # game server will use the saved name to find the name in the Registry
           |> GameServer.reset() # reset the game and get fresh game state
           |> Game.view() # truncate all secrets by passing fresh state to the view() method
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
