/**
 * Returns if the game has ended.
 * @param status the status of the game
 */
export function hasGameEnded(status) {
    return (status === "You won!" || status === "You lost!");
}