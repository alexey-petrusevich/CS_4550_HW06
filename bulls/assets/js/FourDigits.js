import React, {useState, useEffect} from 'react'
import "milligram";
import {hasGameEnded} from "./game";
import {
    ch_push,
    ch_join,
    ch_reset,
    ch_login,
    ch_ready,
    ch_join_as_player,
    ch_join_as_observer
} from "./socket";


function FourDigits() {

    console.log("started four digits")
    // given states
    const [state, setState] = useState({
        playerGuesses: {p1: [], p2: [], p3: [], p4: []},
        playerHints: {p1: [], p2: [], p3: [], p4: []},
        playerNames: [],
        winners: {},
        wins: {},
        losses: {},
        gameState: "",
        status: ""
    });
    // local states
    const [guess, setGuess] = useState("");
    const [gameName, setGameName] = useState("");
    const [playerName, setPlayerName] = useState("");
    const [isGameFull, setIsGameFull] = useState(false);
    const [isUserObserver, setIsUserObserver] = useState(false);

    let {
        playerGuesses,
        playerHints,
        playerNames,
        winners,
        wins,
        losses,
        gameState,
        status
    } = gameState;


    useEffect(() => {
        ch_join(setState)
    })


    // IF STATEMENTS THAT DIRECTLY UPDATE STATE

    // check if game is full to update elements
    if (gameState === "gameFull") {
        setIsGameFull(true);
    } else {
        setIsGameFull(false);
    }

    // check if user is a player to update elements
    if (playerNames.includes(playerName)) {
        setIsUserObserver(false);
    } else {
        setIsUserObserver(true);
    }


    // FUNCTIONS THAT DIRECTLY UPDATE STATE

    // updates the guess state
    function update_guess(input) {
        setGuess(input.target.value)
    }

    // updates the playerName state
    function update_playername(input) {
        setPlayerName(input.target.value)
    }

    // updates the gameName state
    function update_gamename(input) {
        setGameName(input.target.value)
    }


    // FUNCTIONS THAT COMMUNICATE CHANGES TO THE CHANNEL

    // calls ch_login to get game information
    function login() {
        ch_login({gameName: gameName});

        if (gameState === "setUp" || gameState === "gameFull" || gameState === "gameOver") {
            JoinPage();
        }

        if (gameState === "playing") {
            if (playerNames.includes(playerName)) {
                PlayingPage();
            } else {
                ch_join_as_observer({gameName: gameName});
                PlayingPage();
            }
        }
    }

    // marks a player as ready
    function ready() {
        ch_ready({playerName: playerName, gameName: gameName});
    }

    // user joins game as observer
    function join_as_observer() {
        ch_join_as_observer({gameName: gameName});

        if (gameState === "setUp" || gameState === "gameFull" || gameState === "gameOver") {
            WaitingPage();
        }

        if (gameState === "playing") {
            PlayingPage();
        }
    }

    // user joins game as player
    function join_as_player() {
        ch_join_as_player({playerName: playerName, gameName: gameName});
        WaitingPage();
    }

    // user makes guess
    function make_guess() {
        ch_push({guess: guess, playerName: playerName, gameName: gameName});
    }

    // reset the game or something
    function reset() {
        console.log("game reset");
        ch_reset({gameName: gameName});
    }


    // FUNCTIONS RELATED TO LOGIN PAGE

    // returns the login page html
    function LoginPage() {
        return (
            <div>
                <div className="container">
                    <h1 style="text-align:center">Bulls and Cows</h1>
                    <h2 style="text-align:center">Multiplayer Login</h2>
                    <form>
                        <fieldset>
                            <label>Game ID</label>
                            <input
                                type="text"
                                id="sourceText"
                                placeholder="roomtown123"
                                onChange={update_gamename}
                                required
                            />
                            <label>User ID</label>
                            <input
                                type="text"
                                id="username"
                                placeholder="coolguy456"
                                onChange={update_username}
                                required
                            />
                            <input
                                type="submit"
                                onClick={login}
                                value="Login"
                            />
                        </fieldset>
                    </form>
                </div>
            </div>
        );
    }


    // FUNCTIONS RELATED TO JOIN PAGE

    // returns the join page html
    function JoinPage() {
        return (
            <div>
                <div className="container" style="text-align:center">
                    <h1>Bulls and Cows</h1>
                    <h2>Join {gameName} as</h2>
                    <br/>
                    <form>
                        <fieldset>
                            <input
                                type="submit"
                                onClick={join_as_player}
                                value="Player"
                                disabled={isGameFull}
                            />
                            <input
                                type="submit"
                                onClick={join_as_observer}
                                value="Observer"
                            />
                        </fieldset>
                    </form>
                </div>
            </div>
        );
    }


    // FUNCTIONS RELATED TO WAITING PAGE

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


    // FUNCTIONS RELATED TO PLAYING PAGE

    // passes a turn
    function pass() {
        setGuess("");
        make_guess();
    }

    // returns the playing page html
    function PlayingPage() {
        let guessesHints = [];
        for (let i = 0; i < playerGuesses.p1.length; ++i) {
            guessesHints.push(
                <tr>
                    <td>{playerGuesses.p1[i]}</td>
                    <td>{playerHints.p1[i]}</td>
                    <td>{playerGuesses.p2[i]}</td>
                    <td>{playerHints.p2[i]}</td>
                    <td>{playerGuesses.p3[i]}</td>
                    <td>{playerHints.p3[i]}</td>
                    <td>{playerGuesses.p4[i]}</td>
                    <td>{playerHints.p4[i]}</td>
                </tr>
            );
        }

        return (
            <div>
                <div className="container" style="text-align:center">
                    <h1>Bulls and Cows</h1>
                    {/*<h2>GO! Timer: </h2>//(https://www.w3schools.com/howto/howto_js_countdown.asp)</h2>*/}
                    <table>
                        <tr>
                            <th>{players[0]}</th>
                            <th/>
                            <th>{players[1]}</th>
                            <th/>
                            <th>{players[2]}</th>
                            <th/>
                            <th>{players[3]}</th>
                            <th/>
                        </tr>
                        <tr>
                            <th>Guess:</th>
                            <th>Hint:</th>
                            <th>Guess:</th>
                            <th>Hint:</th>
                            <th>Guess:</th>
                            <th>Hint:</th>
                            <th>Guess:</th>
                            <th>Hint:</th>
                        </tr>
                        {guessesHints}
                    </table>
                    <input
                        type="text"
                        onChange={update_guess}
                        placeholder="####"
                        maxLength="4"
                        minLength="4"
                        disabled={isUserObserver}
                    />
                    <input
                        type="submit"
                        onClick={make_guess}
                        value="Submit Guess"
                        disabled={isUserObserver}
                    />
                    <input
                        type="submit"
                        onClick={pass}
                        value="Pass"
                        disabled={isUserObserver}
                    />
                    <input
                        type="button"
                        onClick={LoginPage}
                        value="Leave Game"
                    />
                    <input
                        type="button"
                        onClick={reset}
                        value="Reset Game"
                    />
                </div>
            </div>
        );
    }

    return LoginPage();
}

export let gameName;
export default FourDigits;
