import React, {useState, useEffect} from 'react'
import "milligram";
import {hasGameEnded} from "./game";
import {ch_push, ch_join, ch_reset, ch_login} from "./socket";

// TODO: update the game such that it gets username and game name before
// TODO: proceeding to the game
// TODO: add button select - player or observer

function FourDigits() {
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
    // for textfield
    const [guess, setGuess] = useState("");
    const [gameName, setGameName] = useState("");
    export default gameName;
    const [playerName, setPlayerName] = useState("");


    // TODO: add exit button to playing screen
    // TODO (NOTE): if a player leaves the game at any moment, he is considered AFK and the game
    // TODO (NOTE): as if the player is still in the game but subimts passes
    // TODO: add reset button on the playing page
    // TODO: add wins/losses statistics to the setup page

    let {playerGuesses, playerHints, playerNames, gameName, gameState} = gameState;

    useEffect(() => {
        ch_join(setState)
    })




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

    function join_game() {
            ch_login({playerName: playerName, gameName: gameName})
        }

    // calls ch_push to make guess
    function make_guess() {
        ch_push({playerName: playerName, guess: guess});
    }

    // resets the game or something
    function reset() {
        console.log("game reset");
        ch_reset();
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
                                    onClick={join_game}
                                    value="Join Game"
                                />
                            </fieldset>
                        </form>
                    </div>
                </div>
            );
        }


    // FUNCTIONS RELATED TO JOIN AS PAGE



    // FUNCTIONS RELATED TO SETUP PAGE



    // FUNCTIONS RELATED TO PLAYING PAGE

    /**
     * Returns a grid containing information about past guesses.
     *
     * @param guesses array with all the guesses
     * @param hints arrays with all the hints
     * @returns {JSX.Element} an element containing a grid with all the info
     * @constructor
     */
    function ResultTable({guesses, hints}) {
        let guessesHints = [];

        // TODO: replace this with for-each loop???
        // TODO: to display guesses and hints based on specifications
        // TODO: remove counter, add columns for each user (guess and hint pair for each player)
        for (let i = 0; i < 8; ++i) {
            guessesHints.push(
                <div className="row">
                    <div className="column">
                        <p>{i + 1}</p>
                    </div>
                    <div className="column">
                        <p>
                            {guesses[i]}
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            {hints[i]}
                        </p>
                    </div>
                </div>
            );
        }

        console.log("result table render");

        return (
            <div className="results">
                <div className="row">
                    <div className="column">
                        <div className="colHeader">
                            <p>Num guesses</p>
                        </div>
                    </div>
                    <div className="column">
                        <div className="colHeader">
                            <p>Guess</p>
                        </div>
                    </div>
                    <div className="column">
                        <div className="colHeader">
                            <p>Hint</p>
                        </div>
                    </div>
                </div>
                {guessesHints}
            </div>
        );
    }

    function join_as_obs() {
        // TODO: implement
    }

    function join_as_play() {
        //     TODO: implement
    }

    function game_not_full() {
        // TODO: implement
    }

    function JoinPage({gameName}) {
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
                                onClick={join_as_play}
                                value="Player"
                                disabled={game_not_full}
                            />
                            <input
                                type="submit"
                                onClick={join_as_obs}
                                value="Observer"
                            />
                        </fieldset>
                    </form>
                </div>
            </div>
        );
    }

    function game_over() {
        // TODO: implement
    }

    function submit_pass() {
        // TODO: implement
    }

    function PlayingPage({players, guesses, results}) {
        return (
            <div>
                <div className="container" style="text-align:center">
                    <h1>Bulls and Cows</h1>
                    <h2>GO! Timer: (https://www.w3schools.com/howto/howto_js_countdown.asp)</h2>
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
                        <tr>
                            <td>{guesses[0][i]}</td>
                            <td>{results[0][i]}</td>
                            <td>{guesses[1][i]}</td>
                            <td>{results[1][i]}</td>
                            <td>{guesses[2][i]}</td>
                            <td>{results[2][i]}</td>
                            <td>{guesses[3][i]}</td>
                            <td>{results[3][i]}</td>
                        </tr>
                    </table>
                    <input
                        type="text"
                        onChange={update_guess}
                        placeholder="####"
                        maxLength="4"
                        minLength="4"
                        disabled={game_over}
                    />
                    <input
                        type="submit"
                        onClick={make_guess}
                        value="Submit Guess"
                        disabled={game_over}
                    />
                    <input
                        type="submit"
                        onClick={submit_pass}
                        value="Pass"
                        disabled={game_over}
                    />
                </div>
            </div>
        );
    }


    function player_ready() {
        // TODO: implement
    }

    function not_sure_what_to_do_here() {
        // TODO: implement
    }


    function WaitingPage({players, ready}) {
        return (
            <div>
                <div className="container" style="text-align:center">
                    <h1>Bulls and Cows</h1>
                    <h2>Waiting on Players</h2>
                    <table>
                        <tr>
                            <th>Player</th>
                            <th>Name</th>
                            <th>Ready?</th>
                        </tr>
                        <tr>
                            <th>1</th>
                            <th>{players[0]}</th>
                            <th>{ready[0]}</th>
                        </tr>
                        <tr>
                            <th>2</th>
                            <th>{players[1]}</th>
                            <th>{ready[1]}</th>
                        </tr>
                        <tr>
                            <th>3</th>
                            <th>{players[2]}</th>
                            <th>{ready[2]}</th>
                        </tr>
                        <tr>
                            <th>4</th>
                            <th>{players[3]}</th>
                            <th>{ready[3]}</th>
                        </tr>
                    </table>
                    <input
                        type="submit"
                        onClick={player_ready}
                        value="Ready"
                        disabled={not_sure_what_to_do_here}
                    />
                </div>
            </div>
        );
    }


    function StatusBar({status}) {
        return (
            <div className="status">
                <div className="row">
                    <div className="column">
                        <p>
                            {status}
                        </p>
                    </div>
                </div>
            </div>
        );
    }



}


export default FourDigits;
