defmodule FourDigits.Game do

  # TODO: figure out where to put the global statistcs map??
  # TODO: maybe use backup agent???

  # returns a new state of the game
  def new() do
    %{
      playerGuesses: %{
        p1: [],
        p2: [],
        p3: [],
        p4: []
      },
      playerHints: %{
        p1: [],
        p2: [],
        p3: [],
        p4: []
      },
      playerNames: [],
      playerMap: %{
        # this is used to map player names with p1-p4 (may not need this)
        p1: "",
        p2: "",
        p3: "",
        p4: ""
      },
      winners: %{
        p1: false,
        p2: false,
        p3: false,
        p4: false
      },
      gameState: :setUp, # :setUp :playing :gameOver
      status: "Winner: {list of winners}",
      secret: generateSecret()
    }
  end

  # TODO: implement state changes as pure functions (oldState, event) -> newState

  def playersReachedLimit(oldState, event) do

    # TODO: create new state from old state
    #    newState = Objects.copy(oldsState, {gameState: setUpMax})
    newState
  end

  # returns the player atom given the game state and the playerName
  # value in the map
  def getPlayerAtom(gameState, playerName) do
    mapKeys = gameState.playerMap.keys()
    getPlayerAtomHelp(mapKeys, gameState.playerMap, playerName)
  end

  # helper that returns an atom key in the map given set of map keys,
  # the map which keys belong to, and the value (playerName)
  def getPlayerAtomHelp(mapKeys, map, playerName) do
    if (Map.fetch(map, hd(mapKeys)) == playerName) do
      hd(mapKeys)
    else
      getPlayerAtomHelp(tl(mapKeys), map, playerName)
    end
  end

  # updates the hints of the given game state given player name
  # and a new guess
  def updateHints(gameState, playerName, newGuess) do
    # get a guess for the hint
    newHint = getHint(gameState.secret, newGuess)
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    # retrieve the list of hints for the given player
    playerHintsList = Map.get(gameState.playerHints, player)
    # update the list of hints of the given payer with new hint
    playerHintsList = playerHintsList ++ [newHint]
    # update player hints map
    playerHints = Map.put(gameState.playerHints, player, playerHintsList)
    # update hints of the corresponding player
    %{gameState | playerHints: playerHints}
  end

  # updates the guesses of the given game state given player name
  # and a new guess
  def updateGuesses(gameState, playerName, newGuess) do
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    # retrieve the list of guesses for the given player
    playerGuessesList = Map.get(gameState.playerGuesses, player)
    # update the list of guesses of the given payer with new guess
    playerGuessesList = playerGuessesList ++ [newGuess]
    # update player guesses map
    playerGuesses = Map.put(gameState.playerGuesses, player, playerGuessesList)
    # update guesses of the corresponding player
    %{gameState | playerGuesses: playerGuesses}
  end

  def clearStatus(gameState) do
    if (String.length(gameState.status) > 0) do
      %{gameState | status: ""}
    else
      gameState
    end
  end

  # clears the status if it isn't empty
  def checkStatus(gameState, playerName, newGuess) do
    player = getPlayerAtom(gameState, playerName)
    playerGuesses = Map.get(gameState.playerGuesses, player)
    #def hasGameWon(guesses, secret, newGuess) do
    # if the game has been won, update the player who won
    # and the status
    if (hasGameWon(playerGuesses, gameState.secret, newGuess)) do
      newState = gameState
      %{newState | status: ""}
    else
      # else clear the status if it isn't empty
      clearStatus(gameState)
    end
  end

  # replacement for FourDigits.js version of makeGuess
  # %{p1: "1234"}
  def makeGuess(gameState, playerName, newGuess) do
    # validate the guess and if valid update gamestate
    if (isValidInput(newGuess)) do
      #      cond do
      #        # TODO check if the player has won
      #        hasGameWon(gameState.guesses, gameState.secret, newGuess) ->
      #          %{gameState | status: "You won!"}
      #        hasGameLost(gameState.guesses) ->
      #          %{gameState | status: "You lost!"}
      #        true ->

      # update hints
      newState = updateHints(gameState, playerName, newGuess)
      # update guesses
      newState = updateGuesses(newState, playerName, newGuess)
      # check the game status (e.g. if anyone won the game)
      checkStatus(newState, playerName)
    end
  else
    # new guess is not valid, update game state with new status
    %{
      gameState |
      status: playerName <> ":> " <>
                            "A guess must be a 4-digit unique integer (1-9)"
    }
  end
end

# returns true if input is a valid guess and false otherwise
# NOTE: does not check uniqueness
def isValidInput(input) do
  if (String.length(input) < 4) do
    false
  else
    strList = String.codepoints(input)
    isValidInputHelper(strList)
  end
end

# helper for isValidInput, but accept a list of characters
def isValidInputHelper(list) do
  if (length(list) > 0) do
    isValidChar(hd(list)) && isValidInputHelper(tl(list))
  else
    true
  end
end

# returns true if given character is valid for isValidInput
def isValidChar(char) do
  iValue = Integer.parse(char)
  cond do
    iValue == :error -> false
    elem(iValue, 0) < 1 -> false
    true -> true
  end
end

# returns a hint (string) given a guess (string)
# assumes that secret.length and guess.length are equal
def getHint(secret, guess) do
  secretList = String.codepoints(secret)
  guessList = String.codepoints(guess)
  hintCounts = %{numA: 0, numB: 0}
  # this call returns a map with hintCounts populated
  hintCounts = getHintHelper(secretList, secretList, guessList, hintCounts)
  hintMapToString(hintCounts)
end

# returns a string representation of the given map of hints
def hintMapToString(map) do
  result = ""
  result = result <> to_string(elem(Map.fetch(map, :numA), 1))
  result = result <> "A"
  result = result <> to_string(elem(Map.fetch(map, :numB), 1))
  result = result <> "B"
  result
end

# returns a map containing As and Bs for bulls and cows game
# assumes secretList, and guessList have same length
def getHintHelper(secretListOriginal, secretList, guessList, hintCounts) do
  if (length(secretList) > 0) do
    cond do
      # A - places match
      hd(secretList) == hd(guessList) ->
        getHintHelper(
          secretListOriginal,
          tl(secretList),
          tl(guessList),
          %{hintCounts | numA: hintCounts.numA + 1}
        )
      # B - secret contains a guess character
      Enum.member?(secretListOriginal, hd(guessList)) ->
        getHintHelper(
          secretListOriginal,
          tl(secretList),
          tl(guessList),
          %{hintCounts | numB: hintCounts.numB + 1}
        )
      true -> # nothing found, check rest
        getHintHelper(
          secretListOriginal,
          tl(secretList),
          tl(guessList),
          hintCounts
        )
    end
  else
    hintCounts
  end
end

# returns true if game has been lost
def hasGameLost(guesses) do
  length(guesses) >= 7
end

def hasGameWon(guesses, secret, newGuess) do
  Enum.member?(guesses, secret) || (newGuess == secret)
end

# returns a view to the user (what the user should see)
def view(state) do
  %{
    playerGuesses: state.playerGuesses,
    playerHints: state.playerHints,
    playerNames: state.playerNames,
    winners: state.winners,
    gameState: state.gameState,
    status: state.status
  }
end





# generates a random 4-digit integer
def generateSecret() do
  temp = [1, 2, 3, 4, 5, 6, 7, 8, 9]
  # result here contains a map of four integers
  result = generateSecretHelp(temp, MapSet.new, 4)
  # translate map into 4-character string
  mapToString(MapSet.to_list(result), "");
end

# returns a string representation of the list (map)
def mapToString(list, result) do
  if (length(list) > 0) do
    result = result <> to_string(hd(list))
    mapToString(tl(list), result)
  else
    result
  end
end

# returns a mapSet containing 4 unique integers
def generateSecretHelp(list, mapSet, count) do
  if (count > 0) do
    el = Enum.random(list)
    mapSet = MapSet.put(mapSet, el)
    list = List.delete(list, el)
    generateSecretHelp(list, mapSet, count - 1)
  else
    mapSet
  end
end

end
