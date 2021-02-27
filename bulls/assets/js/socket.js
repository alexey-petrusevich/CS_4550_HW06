import {Socket} from "phoenix";

let socket = new Socket(
    "/socket",
    {params: {token: ""}}
);

socket.connect()

let channel = socket.channel("game:1", {})

let state = {
  playerGuesses: new Map([["p1", []], ["p2", []], ["p3", []], ["p4", []]]),
  playerHints: new Map([["p1", []], ["p2", []], ["p3", []], ["p4", []]]),
  playerNames: [],
  observerNames: [],
  playersReady: new Map(
      [["p1", false], ["p2", false], ["p3", false], ["p4", false]]),
  wins: new Map(),
  losses: new Map(),
  gameState: "",
  status: ""
};

let callback = null;

function state_update(st) {
  console.log("New State", st);
  console.log("type of state? " + (typeof st))
  console.log("type of map? " + (typeof st.wins))
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

// update the socket with new channel given the name of the game
function updateChannel(gameName) {
  console.log("in updateChannel, gameName = " + gameName)
  channel = socket.channel("game:" + gameName, {})
  channel.join()
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("Unable to join to channel", resp)
  });
  console.log("state received from calling join to the server: " + state)
  channel.on("view", state_update(state));
}

export function ch_login(playerName, gameName) {
  // update channel with new gameName
  updateChannel(gameName)

  console.log(
      "ch_login called, playerName: " + playerName + " gameName: " + gameName)
  channel.push("login", {playerName: playerName})
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("unable to login", resp)
  });
}

export function ch_ready(playerName, gameName) {
  // update channel with new gameName
  updateChannel(gameName)

  console.log("ch_ready called")
  channel.push("ready", {playerName: playerName})
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("unable to select ready", resp)
  });
}

export function ch_join_as_observer(observerName, gameName) {
  // update channel with new gameName
  updateChannel(gameName)

  console.log("ch_join_as_observer called")
  channel.push("join_as_observer", {observerName: observerName})
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("unable to join as observer", resp)
  });
}

export function ch_join_as_player(playerName, gameName) {
  // update channel with new gameName
  updateChannel(gameName)

  console.log("ch_join_as_player called")
  channel.push("join_as_player", {playerName: playerName})
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("unable to join as player", resp)
  });
}

export function ch_push(guess, playerName, gameName) {
  // update channel with new gameName
  updateChannel(gameName)

  channel.push("guess", {guess: guess, playerName: playerName})
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("unable to push", resp)
  });
}

export function ch_reset(gameName) {
  // update channel with new gameName
  updateChannel(gameName)

  console.log("ch_reset called")
  channel.push("reset", {})
  .receive("ok", state_update)
  .receive("error", resp => {
    console.log("unable to reset", resp)
  });
}
