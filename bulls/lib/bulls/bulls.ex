defmodule FourDigits.Game do


  # returns a new state of the game
  def new(gameName) do
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
      playersReady: %{
        p1: false,
        p2: false,
        p3: false,
        p4: false
      },
      currentGuesses: %{
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
      wins: %{}, # keeps track of all the players' wins
      losses: %{}, # keeps track of all the players' losses
      gameState: :setUp, # :setUp :gameFull :playing :gameOver
      gameName: gameName,
      status: "",
      secret: generateSecret()
    }
  end


  # updates given game state with a new user joins
  def updateJoin(gameState, playerName) do
    if (gameState.gameState == :playing
        || isGameFull(gameState)) do
      # game in progress or full - no update
      gameState
    else
      # else add new player
      # add player to the list of playerNames
      playerNames = gameState.playerNames ++ [playerName]
      newState = %{gameState | playerNames: playerNames}
      # add player to the playerMap
      newState = addToPlayerMap(newState, playerName)
      # add player to wins and losses (if not present)
      newState = addToWinsLosses(newState, playerName)
      # check if the game is full
      if (isGameFull(newState)) do
        # game is full, update game state
        %{newState | gameState: :gameFull}
      else
        # else game is not full - do not update gameState
        newState
      end
    end
  end

  # adds new player to the wins and losses maps
  # if player is already there, returns original gameState
  # assumes that both or neither wins and losses have the player
  def addToWinsLosses(gameState, playerName) do
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    wins = gameState.wins
    losses = gameState.losses
    if (Map.get(wins, player) == nil) do
      # add new entry
      wins = Map.put(wins, playerName, 0)
      losses = Map.put(losses, playerName, 0)
      newSate = %{gameState | wins: wins}
      newState = %{newState | losses: losses}
      newState
    else
      # else return original game state
      gameState
    end
  end


  # adds a given playerName to the playerMap
  def addToPlayerMap(gameState, playerName) do
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    keys = Map.keys(gameState.playerMap)
    addToPlayerMapHelper(gameState, playerName, keys)
  end

  #
  def addToPlayerMapHelper(gameState, playerName, keys) do
    if (length(keys) == 0) do
      # end of list - player cannot be added
      raise "Error: trying to add player to the full game (addPlayerMap)"
    else
      if (Map.get(gameState.playerMap, hd(keys)) == nil) do
        # found empty spot - add playerName
        newPlayerMap = Map.put(gameState.playerMap, hd(keys), playerName)
        %{gameState | playerMap: newPlayerMap}
      else
        # else check next spot
        addToPlayerMapHelper(gameState, playerName, tl(keys))
      end
    end
  end


  # returns the game state when the given player
  # marks himself as ready
  def toggleReady(gameState, playerName) do
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    if (player == nil
        || isGameOver(gameState)
        || isGameInProgress(gameState)) do
      # do nothing if either player not found, game over,
      # or game is progress
      gameState
    else
      # else update players ready
      playersReady = %{gameState.playersReady | player: true}
      # update game state with new players ready
      newState = %{gameState | playersReady: playersReady}
      # check if state change is required
      if (isAllReady(newState, newState.playerNames)) do
        # change the game state to ready
        %{newState | gameState: :playing}
      else
        # at least one player is not ready
        newState
      end
    end
  end

  # return true if the game is full (e.g. the number
  # of players has reached 4
  def isGameFull(gameState) do
    length(gameState.playerNames) >= 4
  end

  # returns true if the given gameState is in the :gameOver state
  def isGameOver(gameState) do
    gameState.gameState == :gameOver
  end


  # returns true if the game is in the :setUp state
  def isGameInSetUp(gameState) do
    gameState.gameState == :setUp
  end


  # returns true if all players are ready
  def isAllReady(gameState, playerNames) do
    if (length(playerNames) == 0) do
      true
    else
      isPlayerReady(gameState, hd(playerNames))
      && isAllReady(gameState, tl(playerNames))
    end
  end

  # returns true if given player is ready
  # assumes that playerName is in the list (map) of players
  def isPlayerReady(gameState, playerName) do
    player = getPlayerAtom(gameState, playerName)
    Map.get(gameState.playersReady, player)
  end

  def isGameInProgress(gameState) do
    gameState.gameState == :playing
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
    if (Map.get(map, hd(mapKeys)) == playerName) do
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


  # clears the status of the game state
  def clearStatus(gameState) do
    if (String.length(gameState.status) > 0) do
      %{gameState | status: ""}
    else
      gameState
    end
  end


  # checks if there are any winners in the given game
  # and updates the game state accordingly
  def checkWinners(gameState) do
    # update winners list (actually map)
    newState = updateWinnersList(gameState, gameState.playerNames)
    # check if there is at least one winner
    if (hasWinner(newState, newState.playerNames)) do
      # TODO: increment wins and losses

      # update game state to gameOver
      %{newState | gameState: :gameOver}
    else
      # else no winners, return
      newState
    end
  end


  # returns true if there is at least one winner
  def hasWinner(gameState, playerNames) do
    if (length(playerNames) == 0) do
      # if reached the end of the list, no winners
      false
    else
      # get the first element from the player names
      playerName = hd(playerNames)
      # get player atom (key) given playerName
      player = getPlayerAtom(gameState, playerName)
      # check if winners map for this player is true
      if (Map.get(gameState.winners, player)) do
        # has at least one winner, return true
        true
      else
        # else check the rest of the list
        hasWinner(gameState, tl(playerNames))
      end
    end
  end


  # given the game state, updates the status of the game to the list of winners
  # (if any)
  def updateWinnerStatus(gameState) do
    if (hasWinner(gameState, gameState.playerNames)) do
      # there is at least one winner - update status
      updateWinnersStatusHelper(gameState, "Winners: ", gameState.playerNames)
    else
      # no winners - no need to update status
      gameState
    end
  end


  # a helper method for updateWinnerStatus
  def updateWinnersStatusHelper(gameState, status, playerNames) do
    if (length(playerNames) == 0) do
      # end of list, return game state with updates status
      %{gameState | status: trim(status)}
    else
      # get the first element from the player names
      playerName = hd(playerNames)
      # get player atom (key) given playerName
      player = getPlayerAtom(gameState, playerName)
      if (Map.get(gameState.winner, player)) do
        updateWinnersStatusHelper(gameState, status <> playerName <> " ")
      else
      end
    end
  end


  # updates the winners map
  # IMPORTANT NOTE: the list of current guesses shall not be cleared at this point
  # the return state will have updated the map of winners stored withing game state
  def updateWinnersList(gameState, playerNames) do
    if (length(playerNames) == 0) do
      # winners list has been updated
      gameState
    else
      # get the first element from the player names
      playerName = hd(playerNames)
      # get player atom (key) given playerName
      player = getPlayerAtom(gameState, playerName)
      # get player's current guess
      currentGuess = Map.get(gameState.currentGuesses, player)
      # check if the guess is correct
      if (isCorrectGuess(gameState, currentGuess)) do
        # guess is correct, update the winners list and recur
        newWinners = Map.put(gameState.winners, player, true)
        newState = %{gameState, winners: newWinners}
        updateWinnersList(newState, tl(playerNames))
      else
        # else player did not guess right: recur with the rest of the list
        updateWinnersList(gameState, tl(playerNames))
      end
    end
  end


  # returns true if the given guess the same as secret
  def isCorrectGuess(gameState, currentGuess) do
    gameState.secret == currentGuess
  end


  # updates current guesses in the given game state given
  # player name and a new guess
  def updateCurrentGuesses(gameState, playerName, newGuess) do
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    # create new map of current guesses with updated value
    currentGuesses = Map.put(gameState.currentGuesses, player, newGuess)
    # update game state with new current guesses map
    %{gameState | currentGuesses: currentGuesses}
  end


  # makes a new guess for the given player
  # adds the given guess to the currentGuesses map (not all the guesses for the given player)
  def makeGuess(gameState, playerName, newGuess) do
    # validate the guess and if valid update gamestate
    if (isValidInput(newGuess)) do
      # update current guesses of the given player
      newState = updateCurrentGuesses(gameState, playerName, newGuess)
      # clear the status if it isn't clear
      clearStatus(newState)
    end
  else
    # new guess is not valid, update game state with new status
    %{
      gameState |
      status: playerName <> ":> " <>
                            "A guess must be a 4-digit unique integer (1-9)"
    }
  end


  # makes the guesses for each player in the game (to be called by :pook)
  def makeAllGuesses(gameState) do
    makeAllGuessesHelper(gameState, gameState.playerNames)
  end


  # a helper function that is used by makeAllGuesses
  # updates the guesses and hints for all the players
  def makeAllGuessesHelper(gameState, playerNames) do
    if (length(playerNames) == 0) do
      # all players have been updated
      gameState
    else
      # get first player name from the list of player names
      playerName = hd(playerNames)
      # get player atom (key) given playerName
      player = getPlayerAtom(gameState, playerName)
      # get player's current guess
      newGuess = Map.get(gameState.currentGuesses, player)
      # update hints
      newState = updateHints(gameState, playerName, newGuess)
      # update guesses - append new guess to the list of guesses
      newState = updateGuesses(newState, playerName, newGuess)
      # update the rest of players
      makeAllGuessesHelper(newState, tl(playerNames))
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


  # returns a view to the user (what the user should see)
  def view(state) do
    %{
      playerGuesses: state.playerGuesses,
      playerHints: state.playerHints,
      playerNames: state.playerNames,
      winners: state.winners,
      gameState: state.gameState,
      gameName: state.gameName,
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
