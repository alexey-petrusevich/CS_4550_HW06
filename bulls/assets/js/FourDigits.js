import React, {useState, useEffect} from 'react'
import "milligram";
import {hasGameEnded} from "./game";
import {ch_push, ch_join, ch_reset} from "./socket";

/*
NOTE (regarding plagiarism):
Lecture notes on React (4 and 5) were used in creating this assignment.
Specifically:
- Hooks via useState;
- Event handlers (named the same or similarly);
- file game.js, which contains helper functions;
- notions of "guesses" similar to "guesses" in hangman;
 */

function FourDigits() {
    const [gameState, setGameState] = useState({
        guesses: [],
        hints: [],
        status: ""
    });
    // for textfield
    const [guess, setGuess] = useState("");

    let {guesses, hints, status} = gameState;

    useEffect(() => {
        ch_join(setGameState)
    })

    /**
     * Event handler for handling change of the text field
     * containing player's guess.
     *
     * @param ev event being invoked by the caller
     */
    function updateGuess(ev) {
        if (hasGameEnded(status)) {
            console.log("update guess -> game ended")
            return;
        }
        let text = ev.target.value;
        let fieldLength = text.length;
        if (fieldLength > 4) {
            text = text.substr(0, 4);
        }
        setGuess(text);
    }


    /**
     * Being called when a user makes a guess by pressing a "guess"
     * button or presses "Enter" key when the guess text field
     * is focused.
     * Makes a guess if the game hasn't ended.
     */
    function makeGuess() {
        ch_push({guess: guess});
    }


    /**
     * Event handler for key presses when the guess text field
     * is focused.
     *
     * @param ev the event invoked by the caller (key press)
     */
    function keypress(ev) {
        if (hasGameEnded(status)) {
            console.log("game ended");
            return;
        }
        if (ev.key === "Enter") {
            console.log("enter pressed");
            makeGuess();
        }
        console.log("key pressed: " + ev.key);
    }


    /**
     * Resets the game by clearing all the sates.
     */
    function reset() {
        console.log("game reset");
        ch_reset();
    }

    return (
        <div>
            <div className="controls">
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
                            <button onClick={makeGuess}>Guess</button>
                            <button onClick={reset}>Reset</button>
                        </p>
                    </div>
                </div>
            </div>

            <ResultTable guesses={guesses} hints={hints}/>

            <StatusBar status={status}/>

        </div>
    );


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


    /**
     * Returns the status bar that displays errors or win/lose message
     * @param status string being placed into the status bar
     * @returns {JSX.Element}      an element containing status info
     * @constructor
     */
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


