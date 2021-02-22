import {Socket} from "phoenix";

let socket = new Socket("/socket", {params: {token: ""}})
socket.connect()

let channel = socket.channel("game:1", {})

let state = {
    guesses: [],
    hints: [],
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
    console.log("ch_join called cb: " + cb)
    callback = cb;
    console.log("calling callback")
    callback(state)
}

export function ch_push(guess) {
    console.log("ch_push called guess: " + guess)
    channel.push("guess", guess)
        .receive("ok", state_update)
        .receive("error", resp => console.log("unable to push", resp));
}

export function ch_reset() {
    console.log("ch_reset called")
    channel.push("reset", {})
        .receive("ok", state_update)
        .receive("error", resp => {
            console.log("unable to push", resp)
        });
}
console.log("calling channel.join")
channel.join()
    .receive("ok", state_update)
    .receive("error", resp => {
        console.log("Unable to join", resp)
    })
console.log("received from join")

export default socket
