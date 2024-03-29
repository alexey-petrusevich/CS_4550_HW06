// completed by using lecture notes of professor Nat Tuck
import {Socket} from "phoenix";

let socket = new Socket(
    "/socket",
    {params: {token: ""}}
);

socket.connect()

// let channel = socket.channel("game:1", {})
let channel;

let state = {
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

let callback = null;

function state_update(st) {
    state = st;
    if (callback) {
        callback(st);
    }
}

export function ch_join(cb) {
    callback = cb;
    callback(state)
}

// update the socket with new channel given the name of the game
function updateChannel(gameName) {
    channel = socket.channel("game:" + gameName, {})
    channel.join()
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("Unable to join to channel", resp)
        });
    channel.on("view", state_update);
}

export function ch_login(playerName, gameName) {
    // update channel with new gameName
    updateChannel(gameName)

    channel.push("login", {playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to login", resp)
        });
}

export function ch_ready(playerName, gameName) {
    // update channel with new gameName
    updateChannel(gameName)
    channel.push("ready", {playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to select ready", resp)
        });
}

export function ch_start(gameName) {
    updateChannel(gameName)
    channel.push("start", {gameName: gameName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to start the game", resp)
        });
    //channel.on("view", state_update);
}

export function ch_join_as_observer(observerName, gameName) {
    // update channel with new gameName
    updateChannel(gameName)
    channel.push("join_as_observer", {observerName: observerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to join as observer", resp)
        });
}

export function ch_join_as_player(playerName, gameName) {
    // update channel with new gameName
    updateChannel(gameName)
    channel.push("join_as_player", {playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to join as player", resp)
        });
}

export function ch_push(guess, playerName, gameName) {
    // update channel with new gameName
    updateChannel(gameName);
    channel.push("guess", {guess: guess, playerName: playerName})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to push", resp)
        });
}

export function ch_reset(gameName) {
    // update channel with new gameName
    updateChannel(gameName)

    channel.push("reset", {})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to reset", resp)
        });
}

export function ch_leave(state) {
    state_update(state)
}

// channel.on("view", state_update);
