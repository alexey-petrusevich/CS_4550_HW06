import React, {useState, useEffect} from 'react'
import "milligram";
import {
  ch_push,
  ch_join,
  ch_reset,
  ch_login,
  ch_ready,
  ch_join_as_player,
  ch_join_as_observer
} from "./socket";

// to hold the value of the game
let playerName = "";
let gameName = "";

// returns a login page component
function LoginPage() {
  const [playerNameState, setPlayerNameState] = useState("");
  const [gameNameState, setGameNameState] = useState("");

  function updatePlayerName(ev) {
    setPlayerNameState(ev.target.value)
  }

  function updateGameNameState(ev) {
    setGameNameState(ev.target.value)
  }

  function login() {
    ch_login(playerNameState, gameNameState);
    playerName = playerNameState;
    gameName = gameNameState;
  }

  return (
      <div className="row">
        <div className="column">
          <h1>Bulls and Cows</h1>
          <h2>Multiplayer Login</h2>
          <label>User ID</label>
          <input
              type="text"
              value={playerNameState}
              onChange={updatePlayerName}
          />
          <label>Game ID</label>
          <input
              type="text"
              value={gameNameState}
              onChange={updateGameNameState}
          />
          <button onClick={login}>Login</button>
        </div>
      </div>
  );
}

// returns join game component
function JoinPage({state}) {
  function asPlayer() {
    ch_join_as_player(playerName, gameName)
  }

  function asObserver() {
    ch_join_as_observer(gameName)
  }

  function isGameFull() {
    return state.gameState === "gameFull";
  }

  return (
      <div className="row">
        <div className="column">
          <h1>Bulls and Cows</h1>
          <h2>Join {gameName} as</h2>
          <br/>
          <button onClick={asPlayer} disabled={isGameFull()}>Player</button>
          <button onClick={asObserver}>Observer</button>
        </div>
      </div>
  );
}

// returns waiting page component
function WaitingPage({state}) {

  function isObserver() {
    let playerNames = state.playerNames;
    return playerNames.includes(playerName);
  }

  function ready() {
    ch_ready(playerName, gameName);
  }

  function makeStatistics() {
    let winsLosses = [];
    let wins = state.wins;
    let losses = state.losses;
    let playerNames = Array.from(wins.keys());
    let numEntries = playerNames.length;

    // push header
    winsLosses.push(
        <div className="row">
          <div className="column">
            <p>Player Name</p>
          </div>
          <div className="column">
            <p>
              Wins
            </p>
          </div>
          <div className="column">
            <p>
              Losses
            </p>
          </div>
        </div>
    )

    // push statistics
    for (let i = 0; i < numEntries; ++i) {
      let playerName = playerNames[i];
      winsLosses.push(
          <div className="row">
            <div className="column">
              <p>{playerName}</p>
            </div>
            <div className="column">
              <p>
                {wins.get(playerName)}
              </p>
            </div>
            <div className="column">
              <p>
                {losses.get(playerName)}
              </p>
            </div>
          </div>
      );
    }

    return winsLosses;
  }

  let winsLosses = makeStatistics();

  return (
      <div className="row">
        <div className="column">
          <h1>Bulls and Cows</h1>
          <h2>Waiting on Players</h2>
          <button onClick={ready} disabled={isObserver()}>Ready</button>
          {winsLosses}
        </div>
      </div>
  );
}

// TODO: change -> taken from hangman
function Play({state}) {
  let {name, word, guesses} = state;

  let view = word.split('');
  let bads = [];

  function guess(newGuess) {
    // Inner function isn't a render function
    ch_push({guess: newGuess});
  }

  function reset() {
    console.log("FourDigits.reset() called");
    ch_reset();
  }

  return (
      <div>
        <div className="row">
          <div className="column">
            <p>Word: {view.join(' ')}</p>
          </div>
          <div className="column">
            <p>Name: {name}</p>
          </div>
        </div>
        <div className="row">
          <div className="column">
            <p>Guesses: {guesses.join(' ')}</p>
          </div>
        </div>
        <Controls reset={reset} guess={guess}/>
      </div>
  );
}

// this component gets passed to the "root"
function FourDigits() {

  let body;
  //
  // console.log("started four digits")
  // // given states
  // const [state, setState] = useState({
  //     playerGuesses: {p1: [], p2: [], p3: [], p4: []},
  //     playerHints: {p1: [], p2: [], p3: [], p4: []},
  //     playerNames: [],
  //     winners: {},
  //     wins: {},
  //     losses: {},
  //     gameState: "",
  //     status: ""
  // });
  // // local states
  // const [guess, setGuess] = useState("");
  const [gameName, setGameName] = useState("");
  const [playerName, setPlayerName] = useState("");
  // const [isGameFull, setIsGameFull] = useState(false);
  // const [isUserObserver, setIsUserObserver] = useState(false);
  //
  // let {
  //     playerGuesses,
  //     playerHints,
  //     playerNames,
  //     winners,
  //     wins,
  //     losses,
  //     gameState,
  //     status
  // } = gameState;
  //
  //
  // useEffect(() => {
  //     ch_join(setState)
  // })

  //
  // // IF STATEMENTS THAT DIRECTLY UPDATE STATE
  //
  // // check if game is full to update elements
  // if (gameState === "gameFull") {
  //     setIsGameFull(true);
  // } else {
  //     setIsGameFull(false);
  // }
  //
  // // check if user is a player to update elements
  // if (playerNames.includes(playerName)) {
  //     setIsUserObserver(false);
  // } else {
  //     setIsUserObserver(true);
  // }
  //
  //
  // // FUNCTIONS THAT DIRECTLY UPDATE STATE
  //
  // // updates the guess state
  // function update_guess(input) {
  //     setGuess(input.target.value)
  // }
  //
  // updates the playerName state
  function update_playername(input) {
    setPlayerName(input.target.value)
  }

  //
  // updates the gameName state
  function update_gamename(input) {
    setGameName(input.target.value)
  }

  // FUNCTIONS THAT COMMUNICATE CHANGES TO THE CHANNEL

  // calls ch_login to get game information
  function login() {
    console.log("login() called")
    body = <JoinPage/>
    console.log("body changed to join")
    // ch_login({gameName: gameName});

    // if (gameState === "setUp" || gameState === "gameFull" || gameState === "gameOver") {
    //     return (
    //         <JoinPage/>
    //     );
    // }
    //
    // if (gameState === "playing") {
    //     if (playerNames.includes(playerName)) {
    //         return (
    //             <PlayingPage/>
    //         );
    //
    //     } else {
    //         ch_join_as_observer({gameName: gameName});
    //         return (
    //             <PlayingPage/>
    //         );
    //
    //     }
    // }
  }

  //
  // // marks a player as ready
  // function ready() {
  //     ch_ready({playerName: playerName, gameName: gameName});
  // }
  //
  // // user joins game as observer
  // function join_as_observer() {
  //     ch_join_as_observer({gameName: gameName});
  //
  //     if (gameState === "setUp" || gameState === "gameFull" || gameState === "gameOver") {
  //         WaitingPage();
  //     }
  //
  //     if (gameState === "playing") {
  //         PlayingPage();
  //     }
  // }
  //
  // // user joins game as player
  // function join_as_player() {
  //     ch_join_as_player({playerName: playerName, gameName: gameName});
  //     WaitingPage();
  // }
  //
  // // user makes guess
  // function make_guess() {
  //     ch_push({guess: guess, playerName: playerName, gameName: gameName});
  // }
  //
  // // reset the game or something
  // function reset() {
  //     console.log("game reset");
  //     ch_reset({gameName: gameName});
  // }

  // FUNCTIONS RELATED TO LOGIN PAGE

  // returns the login page html

  //
  //
  // FUNCTIONS RELATED TO JOIN PAGE

  // returns the join page html

  //
  //
  // // FUNCTIONS RELATED TO WAITING PAGE
  //
  // returns the waiting page html
  function WaitingPage({players, ready}) {
    return (
        <div>
          <div className="container" style="text-align:center">
            <h1>Bulls and Cows</h1>
            <h2>Waiting on Players</h2>
            <h3>Last rounds winners: {winners}</h3>
            <table>
              <tr>
                <th>Player:</th>
                <th>Name:</th>
                <th>Wins:</th>
                <th>Losses:</th>
                <th>Ready?</th>
              </tr>
              <tr>
                <td>1</td>
                <td>{players[0]}</td>
                <td>wins[playerNames[0]]</td>
                <td>losses[playerNames[0]]</td>
                <td>{ready[0]}</td>
              </tr>
              <tr>
                <td>2</td>
                <td>{players[1]}</td>
                <td>wins[playerNames[1]]</td>
                <td>losses[playerNames[1]]</td>
                <td>{ready[1]}</td>
              </tr>
              <tr>
                <td>3</td>
                <td>{players[2]}</td>
                <td>wins[playerNames[2]</td>
                <td>losses[playerNames[2]]</td>
                <td>{ready[2]}</td>
              </tr>
              <tr>
                <td>4</td>
                <td>{players[3]}</td>
                <td>wins[playerNames[3]]</td>
                <td>losses[playerNames[3]]</td>
                <td>{ready[3]}</td>
              </tr>
            </table>
            <input
                type="submit"
                onClick={ready}
                value="Ready"
                disabled={isUserObserver}
            />
          </div>
        </div>
    );
  }

  //
  // // FUNCTIONS RELATED TO PLAYING PAGE
  //
  // // passes a turn
  // function pass() {
  //     setGuess("");
  //     make_guess();
  // }
  //
  // // returns the playing page html
  // function PlayingPage() {
  //     let guessesHints = [];
  //     for (let i = 0; i < playerGuesses.p1.length; ++i) {
  //         guessesHints.push(
  //             <tr>
  //                 <td>{playerGuesses.p1[i]}</td>
  //                 <td>{playerHints.p1[i]}</td>
  //                 <td>{playerGuesses.p2[i]}</td>
  //                 <td>{playerHints.p2[i]}</td>
  //                 <td>{playerGuesses.p3[i]}</td>
  //                 <td>{playerHints.p3[i]}</td>
  //                 <td>{playerGuesses.p4[i]}</td>
  //                 <td>{playerHints.p4[i]}</td>
  //             </tr>
  //         );
  //     }
  //
  //     return (
  //         <div>
  //             <div className="container" style="text-align:center">
  //                 <h1>Bulls and Cows</h1>
  //                 {/*<h2>GO! Timer: </h2>//(https://www.w3schools.com/howto/howto_js_countdown.asp)</h2>*/}
  //                 <table>
  //                     <tr>
  //                         <th>{players[0]}</th>
  //                         <th/>
  //                         <th>{players[1]}</th>
  //                         <th/>
  //                         <th>{players[2]}</th>
  //                         <th/>
  //                         <th>{players[3]}</th>
  //                         <th/>
  //                     </tr>
  //                     <tr>
  //                         <th>Guess:</th>
  //                         <th>Hint:</th>
  //                         <th>Guess:</th>
  //                         <th>Hint:</th>
  //                         <th>Guess:</th>
  //                         <th>Hint:</th>
  //                         <th>Guess:</th>
  //                         <th>Hint:</th>
  //                     </tr>
  //                     {guessesHints}
  //                 </table>
  //                 <input
  //                     type="text"
  //                     onChange={update_guess}
  //                     placeholder="####"
  //                     maxLength="4"
  //                     minLength="4"
  //                     disabled={isUserObserver}
  //                 />
  //                 <input
  //                     type="submit"
  //                     onClick={make_guess}
  //                     value="Submit Guess"
  //                     disabled={isUserObserver}
  //                 />
  //                 <input
  //                     type="submit"
  //                     onClick={pass}
  //                     value="Pass"
  //                     disabled={isUserObserver}
  //                 />
  //                 <input
  //                     type="button"
  //                     onClick={LoginPage}
  //                     value="Leave Game"
  //                 />
  //                 <input
  //                     type="button"
  //                     onClick={reset}
  //                     value="Reset Game"
  //                 />
  //             </div>
  //         </div>
  //     );
  // }

  body = <LoginPage/>

  return (
      <div className="container">
        {body}
      </div>
  );
}

export default FourDigits;
