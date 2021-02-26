import {Socket} from "phoenix";

let socket = new Socket(
    "/socket",
    {params: {token: ""}}
);
socket.connect()

let channel = socket.channel("game:1", {})

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

export function ch_login(playerName, gameName) {
    channel.push("login", {playerName: playerName, gameName: gameName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to login", resp)
        });
}

export function ch_push(guess) {
    // TODO: add player name
    channel.push("guess", guess)
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

channel.join()
    .receive("ok", state_update)
    .receive("error", resp => {
        console.log("Unable to join", resp)
    })

channel.on("view", state_update())
