import {Socket} from "phoenix";
import gameName from './FourDigits'

let socket = new Socket(
    "/socket",
    {params: {token: ""}}
);
socket.connect()

let gameVal = "game:" + gameName;
let channel = socket.channel(gameVal, {})

let state = {
    playerGuesses: {p1: [], p2: {}, p3: [], p4: []},
    playerHints: {p1: [], p2: {}, p3: [], p4: []},
    playerNames: [],
    gameName: "",
    gameState: ""
}

let callback = null;

function state_update(st) {
    console.log("New State", st);
    state = st;
    if (callback) {
        callback(st);
    }
}

export function ch_join(cb) {
    callback = cb;
    callback(state)
}

export function ch_login(gameName) {
    channel.push("login", {gameName: gameName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to login", resp)
        });
}

export function ch_join_as_observer(gameName) {
    channel.push("ch_join_as_observer", {gameName: gameName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to login", resp)
        });
}

export function ch_join_as_player(playerName, gameName) {
    channel.push("join_as_player", {playerName: playerName, gameName: gameName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to login", resp)
        });
}

export function ch_push(guess, playerName) {
    channel.push("guess", {playerName: playerName, guess: guess})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to push", resp)
        });
}

export function ch_reset() {
    channel.push("reset", {})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to reset", resp)
        });
}

// TODO: add endpoint for returning wins and losses to the caller
// TODO: like ch_get_wins_losses????

channel.join()
    .receive("ok", state_update)
    .receive("error", resp => {
        console.log("Unable to join", resp)
    })

channel.on("view", state_update())
