// completed by using lecture notes of professor Nat Tuck
import React, {useState, useEffect} from 'react'
import "milligram";
import {
    ch_push,
    ch_join,
    ch_reset,
    ch_login,
    ch_ready,
    ch_start,
    ch_join_as_player,
    ch_join_as_observer,
    ch_leave
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
        ch_join_as_observer(playerName, gameName)
    }

    function isGameFull() {
        return state.gameState === "gameFull";
    }

    return (
        <div className="row">
            <div className="column">
                <h1>Bulls and Cows</h1>
                <h2>Join {gameName} as {playerName}</h2>
                <br/>
                <button onClick={asPlayer}
                        disabled={isGameFull()}>Player
                </button>
                <button onClick={asObserver}>Observer</button>
            </div>
        </div>
    );
}

// returns waiting page component
function WaitingPage({state}) {

    function isObserver() {
        return state.observerNames.includes(playerName);
    }

    function isGameNotFull() {
        return state.gameState !== "gameFull";
    }

    function allPlayersReady() {
        let playersReady = state.playersReady;
        return playersReady["p1"]
            && playersReady["p2"]
            && playersReady["p3"]
            && playersReady["p4"];
    }

    function ready() {
        ch_ready(playerName, gameName);
    }

    function startGame() {
        ch_start(gameName);
    }

    function isGameReady() {
        let a = isGameNotFull();
        let b = !allPlayersReady()
        return a || b;
    }

    function playerReady(readyFlag) {
        if (readyFlag) {
            return "Ready";
        } else {
            return "Not Ready";
        }
    }

    return (
        <div className="container">
            <div className="row">
                <div className="column">
                    <h1>Bulls and Cows</h1>
                    <h2>Waiting on Players</h2>
                    <button onClick={ready}
                            disabled={isObserver()}>Ready
                    </button>
                    <button onClick={startGame}
                            disabled={isGameReady() || isObserver()}>Start
                        Game
                    </button>
                    <div className="row">
                        <div className="column">
                            Player 1
                        </div>
                        <div className="column">
                            Player 2
                        </div>
                        <div className="column">
                            Player 3
                        </div>
                        <div className="column">
                            Player 4
                        </div>
                    </div>
                    <div className="row">
                        <div className="column">
                            {playerReady(state.playersReady.p1)}
                        </div>
                        <div className="column">
                            {playerReady(state.playersReady.p2)}
                        </div>
                        <div className="column">
                            {playerReady(state.playersReady.p3)}
                        </div>
                        <div className="column">
                            {playerReady(state.playersReady.p4)}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

// returns play page with guesses and make guess buttons
function PlayPage({st}) {

    let {playerGuesses, playerHints, status} = st;

    // for text field
    const [guess, setGuess] = useState("");

    function isGameOver() {
        return status === "gameOver";
    }

    function updateGuess(ev) {
        if (!isGameOver()) {
            let text = ev.target.value;
            let fieldLength = text.length;
            if (fieldLength > 4) {
                text = text.substr(0, 4);
            }
            setGuess(text);
        }
    }

    function makeGuess() {
        if (!isGameOver()) {
            ch_push(guess, playerName, gameName);
        }
    }

    function keypress(ev) {
        if (!isGameOver() && ev.key === "Enter") {
            makeGuess();
        }
    }

    function reset() {
        ch_reset();
    }

    function leave() {
        ch_leave(initState);
        playerName = "";
        gameName = "";
    }

    function isObserver() {
        return st.observerNames.includes(playerName);
    }

    function isPlayer() {
        return st.playerNames.includes(playerName);
    }

    return (
        <div>
            <div className="row">
                <div className="column">
                    <p>
                        <input type="text"
                               onChange={updateGuess}
                               value={guess}
                               onKeyPress={keypress}
                        />
                    </p>
                </div>
                <div className="column">
                    <p>
                        <button onClick={makeGuess}
                                disabled={!isPlayer()}>Guess
                        </button>
                        <button onClick={leave}>Leave Game</button>
                    </p>
                </div>
            </div>
            <ResultTable guesses={playerGuesses} hints={playerHints}/>
            <StatusBar status={status}/>
        </div>
    );

    function ResultTable({guesses, hints}) {
        let numEntries = guesses["p1"].length;

        function pushHeader() {
            let guessesHints = []
            // push empty column for turn number
            guessesHints.push(
                <div className="row">
                    <div className="column">
                        <p>Num Guesses</p>
                    </div>
                    <div className="column">
                        <p>
                            P1 Guesses
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P1 Hints
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P2 Guesses
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P2 Hints
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P3 Guesses
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P3 Hints
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P4 Guesses
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            P4 Hints
                        </p>
                    </div>
                </div>
            );
            return guessesHints;
        }

        function pushColumn(value) {
            return (
                <div className="column">
                    <p>{value}</p>
                </div>
            );
        }

        // get header
        let guessesHints = pushHeader();


        // push all guesses and hints
        for (let i = 0; i < numEntries; i++) {
            guessesHints.push(
                <div className="row">
                    <div className="column">
                        <p>{i + 1}</p>
                    </div>
                    {pushColumn(guesses["p1"][i])}
                    {pushColumn(hints["p1"][i])}
                    {pushColumn(guesses["p2"][i])}
                    {pushColumn(hints["p2"][i])}
                    {pushColumn(guesses["p3"][i])}
                    {pushColumn(hints["p3"][i])}
                    {pushColumn(guesses["p4"][i])}
                    {pushColumn(hints["p4"][i])}
                </div>
            );
        }

        return (
            <div>
                {guessesHints}
            </div>
        );
    }

    function StatusBar({status}) {
        return (
            <div>
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

// return game over screen with statistics and reset button
function GameOver({state}) {
    function makeStatistics() {
        let winsLosses = [];
        let wins = state.wins;
        let losses = state.losses;
        let playerNames = Object.keys(wins);
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
                            {wins[playerName]}
                        </p>
                    </div>
                    <div className="column">
                        <p>
                            {losses[playerName]}
                        </p>
                    </div>
                </div>
            );
        }

        return winsLosses;
    }

    let winsLosses = makeStatistics();

    function reset() {
        ch_reset(gameName)
    }

    function isPlayer() {
        return state.playerNames.includes(playerName);
    }


    return (
        <div>
            <div className="row">
                <div className="column">
                    <button onClick={reset}
                    disabled={!isPlayer()}>Reset</button>
                    {winsLosses}
                </div>
            </div>
        </div>
    );
}


const initState = {
    playerGuesses: {},
    playerHints: {},
    playerNames: [],
    observerNames: [],
    playersReady: {},
    wins: {},
    losses: {},
    gameState: "",
    status: ""
};

// this component gets passed to the "root"
function FourDigits() {

    const [state, setState] = useState(initState);

    useEffect(() => {
        ch_join(setState)
    })

    let body;

    function hasRoleSelected() {
        return state.observerNames.includes(playerName)
            || state.playerNames.includes(playerName);
    }

    if (playerName.length === 0) {
        body = <LoginPage/>
    } else if ((state.gameState === "setUp" || state.gameState === "gameFull")
        && hasRoleSelected()) {
        body = <WaitingPage state={state}/>
    } else if (state.gameState === "setUp") {
        body = <JoinPage state={state}/>
    } else if (state.gameState === "playing") {
        body = <PlayPage st={state}/>
    } else {
        body = <GameOver state={state}/>
    }

    return (
        <div className="container">
            {body}
        </div>
    );

}

export default FourDigits;
