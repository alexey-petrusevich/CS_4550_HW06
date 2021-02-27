import {Socket} from "phoenix";
import {gameName} from './FourDigits'

let socket = new Socket(
    "/socket",
    {params: {token: ""}}
);
console.log("connecting to socket")
socket.connect()
console.log("socket connected")

let gameVal = "game:" + gameName;
console.log("gameVal: " + gameVal)
console.log("requesting channel")
let channel = socket.channel(gameVal, {})
console.log("channel requested")

let state = {
    playerGuesses: { p1: [], p2: [], p3: [], p4: [] },
    playerHints: { p1: [], p2: [], p3: [], p4: [] },
    playerNames: [],
    winners: {},
    wins: {},
    losses: {},
    gameState: "",
    status: ""
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
    console.log("ch_join called")
    callback = cb;
    callback(state)
}

export function ch_login() {
    console.log("ch_login called")
    channel.push("login", {})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to login", resp)
        });
}

export function ch_ready(playerName) {
    console.log("ch_ready called")
    channel.push("ready", {playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to select ready", resp)
        });
}

export function ch_join_as_observer() {
    console.log("ch_join_as_observer called")
    channel.push("join_as_observer", {})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to join as observer", resp)
        });
}

export function ch_join_as_player(playerName) {
    console.log("ch_join_as_player called")
    channel.push("join_as_player", {playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to join as player", resp)
        });
}

export function ch_push(guess, playerName) {
    channel.push("guess", {guess: guess, playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to push", resp)
        });
}

export function ch_reset() {
    console.log("ch_reset called")
    channel.push("reset", {})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to reset", resp)
        });
}

console.log("calling join, gameName: " + gameName)

channel.join()
    .receive("ok", state_update)
    .receive("error", resp => {
        console.log("Unable to join", resp)
    })

channel.on("view", state_update())
