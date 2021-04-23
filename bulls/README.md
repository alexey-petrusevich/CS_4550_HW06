# HW06 (Fixed)

---

## Code Atribution

This assignment was based on lecture notes of professor Nat Tuck (CS
4550).

---

## Design Decision

- After the game is over (there is at least one winner), the game
  changes its state to "gameOver" to display the score; any player can
  reset the game by pressing "Reset" button and return to set up
  mode ("setUp" state).
- The game requires to have exactly 4 players in order to play
- There are unlimited number of observer (as requested)
- Wins and losses are associated with each game - that is, if there
  were 4 players (p1, p2, p3, p4)
  in game "game1" and 4 other players in "game2" (p11, p12, p13, p14),
  the game statistics will show only those players who played at least
  once in "game1" or "game2", but not both

---

# Bulls

To start your Phoenix server:

* Install dependencies with `mix deps.get`
* Install Node.js dependencies with `npm install` inside the `assets`
  directory
* Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your
browser.

Ready to run in production?
Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html)
.

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
