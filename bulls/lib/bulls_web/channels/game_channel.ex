defmodule BullsWeb.GameChannel do
  use BullsWeb, :channel

  alias FourDigits.Game
  alias FourDigits.GameServer

  @impl true
  def join("game:" <> gameName, payload, socket) do
    if authorized?(payload) do
      # start game server (a.k.a. initialize new game when joined)
      GameServer.start(gameName)
      # create new socket, and assign game name and game state to the socket
      socket = socket
               # store name of the game in the socket
               |> assign(:gameName, gameName)
      #               |> assign(:game, game)
      # get state of the game from the server (process)
      # here the game should be fresh - no guesses made
      game = GameServer.peek(gameName)
      # truncate any secret info and reveal only what is necessary
      # to the caller
      view = Game.view(game, "")
      # return view back to the caller
      {:ok, view, socket}
    else
      {:error, %{reason: "unauthorized"}}
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
    broadcast(socket, "view", view)
    {:reply, {:ok, view}, socket}
  end


  @impl true
  def handle_in("reset", _, socket) do
    game = Game.new
    socket = assign(socket, :game, game)
    view = Game.view(game)
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
