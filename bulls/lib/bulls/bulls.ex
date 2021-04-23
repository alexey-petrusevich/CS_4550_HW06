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
      observerNames: [],
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
      secret: generateSecret(),
    }
  end


  def updateObserver(gameState, observerName) do
    if (!Enum.member?(gameState.observerNames, observerName)) do
      # observer is not in the list of observer - add to the list
      observerNames = gameState.observerNames ++ [observerName]
      %{gameState | observerNames: observerNames}
    else
      # else observer is already in the list, do nothing
      gameState
    end
  end


  # updates given game state with a new user joins
  def updateJoin(gameState, playerName) do
    IO.inspect("in updateJoin")
    # if the game is full or is playing
    if (!isGameInSetUp(gameState)) do
      # game is not un set up state - no update
      gameState
    else
      IO.inspect("game is in set up")
      # else add new player
      # add player to the list of playerNames

      playerNames = gameState.playerNames ++ [playerName]
      IO.inspect("added playerNames")
      IO.inspect("gameState before updating playerNames")
      IO.inspect(gameState)
      # create new state wth new list of playerNames
      newState = %{gameState | playerNames: playerNames}
      IO.inspect("updated gameState with new names")
      IO.inspect(newState)
      # add player to the playerMap
      newState = addToPlayerMap(newState, playerName)
      IO.inspect("added to playerMap gameState:")
      IO.inspect(newState)
      # add player to wins and losses (if not present)
      newState = addToWinsLosses(newState, playerName)
      IO.inspect("added to wins and losses gameState")
      IO.inspect(newState)
      # check if the game is full, and update game state if so
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
    #IO.inspect("in addToWinsLosses")
    # get player atom (key) given playerName
    #player = getPlayerAtom(gameState, playerName)
    #IO.inspect("got playerAtom")
    #IO.inspect(player)
    # get wins maps
    wins = gameState.wins
    IO.inspect("got player wins")
    IO.inspect(wins)
    # get losses map
    losses = gameState.losses
    IO.inspect("got player losses")
    IO.inspect(losses)
    # if there's no entry for the given player, add this player to the map of
    # wins and losses
    if (Map.get(wins, playerName) == nil) do
      # add new entry to wins
      wins = Map.put(wins, playerName, 0)
      # add new entry to losses
      losses = Map.put(losses, playerName, 0)
      # update state with wins
      newState = %{gameState | wins: wins}
      # update state win losses and return
      %{newState | losses: losses}
    else
      # else player is already in the wins and losses map - return original game state
      gameState
    end
  end


  # adds a given playerName to the playerMap
  def addToPlayerMap(gameState, playerName) do
    # get player atom (key) given playerName
    # get all the ksy from the player map (e.g. p1, p2, p3, p4)
    keys = Map.keys(gameState.playerMap)
    # call helper to add new player to the spare spot in the map
    addToPlayerMapHelper(gameState, playerName, keys)
  end


  # a helper method for addToPlayerMap that iterates through
  # the given set of keys, finds the next spare spot in the map
  # and adds it there
  # NOTE: if not spare spots left, throws an error
  def addToPlayerMapHelper(gameState, playerName, keys) do
    if (length(keys) == 0) do
      # end of list - player cannot be added
      raise "Error: trying to add player to the full game (addPlayerMap)"
    else
      # else there are still spots left - > check if this spot is empty
      if (Map.get(gameState.playerMap, hd(keys)) == "") do
        # found empty spot - add playerName
        newPlayerMap = Map.put(
          gameState.playerMap,
          hd(keys),
          playerName
        )
        # update gameState with new player map and return
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
    # if the player doesn't exist, the game is over or in progress, do nothing
    if (player == nil
        || isGameOver(gameState)
        || isGameInProgress(gameState)) do
      # do nothing if either player not found, game over,
      # or game is progress
      gameState
    else
      # else update players ready
      playersReady = Map.put(gameState.playersReady, player, true)
      # update game state with new players ready
      newState = %{gameState | playersReady: playersReady}
      # check if state change is required, and if so update state to :playing
      # (if every player is ready)
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
    if (length(playerNames) != 4) do
      # if number of players is not 4, then players are not ready
      false
    else
      # otherwise, check if every player is ready
      isAllReadyHelper(gameState, playerNames)
    end
  end

  def isAllReadyHelper(gameState, playerNames) do
    # if all other players are ready, then everyone is ready
    if (length(playerNames) == 0) do
      true
    else
      # else check if this player is ready and the rest are ready
      isPlayerReady(gameState, hd(playerNames))
      && isAllReady(gameState, tl(playerNames))
    end
  end


  # returns true if given player is ready
  # assumes that playerName is in the list (map) of players
  def isPlayerReady(gameState, playerName) do
    player = getPlayerAtom(gameState, playerName)
    # check playersReady map if selected player is ready
    Map.get(gameState.playersReady, player)
  end


  # returns true if the game state is :playing
  def isGameInProgress(gameState) do
    gameState.gameState == :playing
  end


  # returns the player atom given the game state and the playerName
  # value in the map
  def getPlayerAtom(gameState, playerName) do
    # get all the keys from playerMap (p1, p2, p3, p4)
    mapKeys = Map.keys(gameState.playerMap) # p1, p2, p3, p4
    # use the helper to get the right key associated with given player name
    getPlayerAtomHelp(mapKeys, gameState.playerMap, playerName)
  end


  # helper that returns an atom key in the map given set of map keys,
  # the map which keys belong to, and the value (playerName)
  # if playerNa,e nt found returns nil
  def getPlayerAtomHelp(mapKeys, map, playerName) do
    if (length(mapKeys) == 0) do
      # if here, playerName somehow not found in the map
      nil
    else
      # check if the value of the first entry in the list of keys in the given map
      # matches given playerName
      if (Map.get(map, hd(mapKeys)) == playerName) do
        # found the key of the given playerName - return to the caller
        hd(mapKeys)
      else
        # check the rest of the map keys
        getPlayerAtomHelp(tl(mapKeys), map, playerName)
      end
    end
  end


  # updates the hints of the given game state given player name
  # and a new guess
  def updateHints(gameState, playerName, newGuess) do
    # get a hints from the given guess
    newHint = getHint(gameState.secret, newGuess)
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    # retrieve the list of hints for the given player
    playerHintsList = Map.get(gameState.playerHints, player)
    # update the list of hints of the given payer with new hint
    playerHintsList = playerHintsList ++ [newHint]
    # update player hints map
    playerHints = Map.put(
      gameState.playerHints,
      player,
      playerHintsList
    )
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
    playerGuesses = Map.put(
      gameState.playerGuesses,
      player,
      playerGuessesList
    )
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


  # increments wins and losses for all the winners and losers
  def incrementWinsLosses(gameState) do
    IO.inspect("in incrementWinsLosses")
    # get players keys
    playerKeys = Map.keys(gameState.playerMap)
    IO.inspect("got map keys")
    IO.inspect(playerKeys)
    # call helper to increment score for every player in this game
    #IO.inspect("calling stringsAsAtoms")
    #playerNameKeys = stringsAsAtoms(gameState.playerNames, [])
    #IO.inspect("playerNameKeys")
    #IO.inspect(playerNameKeys)
    #IO.inspect("calling incrementWinsLossesHelp")
    ret = incrementWinsLossesHelp(gameState, gameState.playerNames)
    IO.inspect("incrementWInsLossesHelp result")
    IO.inspect(ret)
    ret
  end


  # a helper function that translates a list of playerNames to a list of atoms
  def stringsAsAtoms(playerList, atomList) do
    if (length(playerList) == 0) do
      atomList
    else
      atomList = atomList ++ [String.to_atom(hd(playerList))]
      stringsAsAtoms(tl(playerList), atomList)
    end
  end

  def isPlayerWinner(gameState, playerName) do
    # taken from here
    # https://stackoverflow.com/questions/37375727/how-to-get-key-for-value-in-map
    winnerKey = gameState.playerMap
    |> Enum.find(fn {key, val} -> val == playerName end)
    |> elem(0)
    Map.get(gameState.winners, winnerKey)
  end


  # a helper function that increments all the players given player keys
  def incrementWinsLossesHelp(gameState, playerNameKeys) do
    IO.inspect("in incrementWinsLossesHelp")
    if (length(playerNameKeys) == 0) do
      IO.inspect("end of list of playerNameKeys")
      # game has been updated
      gameState
    else
      IO.inspect("playerNameKeys are not empty")
      playerKey = hd(playerNameKeys)
      IO.inspect("playerKey")
      IO.inspect(playerKey)
      if (!isPlayerWinner(gameState, playerKey)) do
        IO.inspect("incrementing loss")
        # increment losses
        lossCount = Map.get(gameState.losses, playerKey)
        IO.inspect("got loss count")
        IO.inspect(lossCount)
        lossCount = lossCount + 1
        IO.inspect("incremented loss count")
        IO.inspect(lossCount)
        losses = Map.put(gameState.losses, playerKey, lossCount)
        IO.inspect("got new losses")
        IO.inspect(losses)
        newState = %{gameState | losses: losses}
        IO.inspect("updated gameState")
        IO.inspect(newState)
        incrementWinsLossesHelp(newState, tl(playerNameKeys))
      else
        IO.inspect("incrementing win")
        # increment wins
        winCount = Map.get(gameState.wins, playerKey)
        IO.inspect("got win count")
        IO.inspect(winCount)
        winCount = winCount + 1
        IO.inspect("incremented win count")
        IO.inspect(winCount)
        wins = Map.put(gameState.wins, playerKey, winCount)
        IO.inspect("got new wins")
        IO.inspect(wins)
        newState = %{gameState | wins: wins}
        IO.inspect("update Game State")
        IO.inspect(newState)
        incrementWinsLossesHelp(newState, tl(playerNameKeys))
      end
    end
  end


  # checks if there are any winners in the given game
  # and updates the game state accordingly
  # to be called by :pook
  def checkWinners(gameState) do
    IO.inspect("in checkWinner")
    IO.inspect("gameState before calling updateWinner")
    IO.inspect(gameState)
    # update winners list (actually map)
    newState = updateWinnersList(gameState, gameState.playerNames)
    IO.inspect("updated winner list")
    IO.inspect(newState)
    # check if there is at least one winner
    if (hasWinner(newState, newState.playerNames)) do
      IO.inspect("game has winner")
      # increment wins and losses
      newState = incrementWinsLosses(newState)

      IO.inspect("changing game state to GameOver")
      # update game state to gameOver
      %{newState | gameState: :gameOver}
    else
      IO.inspect("no winners")
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
      updateWinnersStatusHelper(
        gameState,
        "Winners: ",
        gameState.playerNames
      )
    else
      # no winners - no need to update status
      gameState
    end
  end


  # a helper method for updateWinnerStatus
  def updateWinnersStatusHelper(gameState, status, playerNames) do
    if (length(playerNames) == 0) do
      # end of list, return game state with updates status
      %{gameState | status: String.trim(status)}
    else
      # get the first element from the player names
      playerName = hd(playerNames)
      # get player atom (key) given playerName
      player = getPlayerAtom(gameState, playerName)
      if (Map.get(gameState.winner, player)) do
        updateWinnersStatusHelper(
          gameState,
          status <> playerName <> " ",
          tl(playerNames)
        )
      else
      end
    end
  end


  # updates the winners map
  # IMPORTANT NOTE: the list of current guesses shall not be cleared at this point
  # the return state will have updated the map of winners stored withing game state
  def updateWinnersList(gameState, playerNames) do
    IO.inspect("in updateWinnerList")
    if (length(playerNames) == 0) do
      # winners list has been updated
      IO.inspect("winner updated")
      gameState
    else
      IO.inspect("updating players")
      # get the first element from the player names
      playerName = hd(playerNames)
      IO.inspect("updating winner")
      IO.inspect(playerName)
      # get player atom (key) given playerName
      player = getPlayerAtom(gameState, playerName)
      IO.inspect("playerAtom")
      IO.inspect(player)
      # get player's current guess
      currentGuess = Map.get(gameState.currentGuesses, player)
      IO.inspect("current guess for this player")
      IO.inspect(currentGuess)
      # check if the guess is correct
      if (isCorrectGuess(gameState, currentGuess)) do
        IO.inspect("guess is correct")
        # guess is correct, update the winners list and recur
        newWinners = Map.put(gameState.winners, player, true)
        IO.inspect("updated winner")
        IO.inspect("newWinner")
        IO.inspect(newWinners)
        newState = %{gameState | winners: newWinners}
        IO.inspect("updated gameState")
        IO.inspect(newState)
        updateWinnersList(newState, tl(playerNames))
      else
        IO.inspect("guess incorrect")
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
    IO.inspect("in updateCurrentGuesses")
    # get player atom (key) given playerName
    player = getPlayerAtom(gameState, playerName)
    IO.inspect("playerAtom")
    IO.inspect(player)
    # create new map of current guesses with updated value
    currentGuesses = Map.put(
      gameState.currentGuesses,
      player,
      newGuess
    )
    IO.inspect("currentGuesses")
    IO.inspect(currentGuesses)
    # update game state with new current guesses map
    newState = %{gameState | currentGuesses: currentGuesses}
    IO.inspect("newState (updateCurrentGuesses)")
    IO.inspect(newState)
    newState
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
    else
      # new guess is not valid, update game state with new status
      %{
        gameState |
        status: playerName <> ":> " <>
                              "A guess must be a 4-digit unique integer (1-9)"
      }
    end
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
    if (length(list) == 0) do
      true
    else
      isValidChar(hd(list)) && isValidInputHelper(tl(list))
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
    hintCounts = getHintHelper(
      secretList,
      secretList,
      guessList,
      hintCounts
    )
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
  def getHintHelper(
        secretListOriginal,
        secretList,
        guessList,
        hintCounts
      ) do
    if (length(guessList) == 0) do
      hintCounts
    else
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
    end
  end


  # returns a view to the user (what the user should see)
  def view(state) do
    %{
      playerGuesses: state.playerGuesses,
      playerHints: state.playerHints,
      playerNames: state.playerNames,
      observerNames: state.observerNames,
      playersReady: state.playersReady,
      wins: state.wins,
      losses: state.losses,
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


  # clears current gasses of the given gameState
  def clearCurrentGuesses(gameState) do
    currentGuesses = gameState.currentGuesses
    currentGuesses = %{currentGuesses | p1: ""}
    currentGuesses = %{currentGuesses | p2: ""}
    currentGuesses = %{currentGuesses | p3: ""}
    currentGuesses = %{currentGuesses | p4: ""}
    %{gameState | currentGuesses: currentGuesses}
  end


  # updates the state of the game to "playing"
  def startGame(gameState) do
    %{gameState | gameState: :playing}
  end
end



