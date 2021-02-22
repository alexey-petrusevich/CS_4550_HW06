defmodule FourDigits.Game do

  # returns new game?
  def new() do
    %{
      guesses: [],
      secret: generateSecret(),
      hints: [],
      status: ""
    }
  end

  # replacement for FourDigits.js version of makeGuess
  def makeGuess(state, newGuess) do
    if (isValidInput(newGuess)) do
      cond do
        hasGameWon(state.guesses, state.secret, newGuess) ->
          %{state | status: "You won!"}
        hasGameLost(state.guesses) ->
          %{state | status: "You lost!"}
        true ->
          newHint = getHint(state.secret, newGuess)
          state = %{state | hints: state.hints ++ [newHint]}
          state = %{state | guesses: state.guesses ++ [newGuess]}
          if (String.length(state.status) > 0) do
            %{state | status: ""}
          else
            state
          end
      end
    else
      %{state | status: "A guess must be a 4-digit unique integer (1-9)"}
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
    # return a map with guesses, hints, and status
    %{
      guesses: state.guesses,
      hints: state.hints,
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
