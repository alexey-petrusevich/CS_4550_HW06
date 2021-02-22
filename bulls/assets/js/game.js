/**
 * Generates a string representing a 4-digit number with each
 * digit 1-9 being unique.
 * @returns {string} representing a 4-digit unique number
 */
export function generateSecret() {
    let temp = new Set();
    while (temp.size < 4) {
        let newNum = Math.ceil(Math.random() * 9);
        temp.add(newNum);
    }
    return ((vars) => {
        let str = "";
        for (let c of vars) {
            str = str.concat(c.toString());
        }
        return str;
    })(temp);
}


/**
 * Checks whether the given input is a 4-digit positive integer
 * with every digit 1-9 being unique.
 * @param input the input being checked for validity
 * @returns {boolean} "true" if input is valid and "false" otherwise
 */
export function isValidInput(input) {
    let temp = new Set(input.split(""));
    if (temp.size < 4) {
        console.log("size is less than 4")
        return false;
    }
    for (let value of temp) {
        let iValue = parseInt(value);
        if (isNaN(iValue) || iValue < 1) {
            console.log("value is not a 1-9 number")
            return false;
        }
    }
    return true;
}


/**
 * Returns a hint representing the number of digits in right
 * positions ("A") and being present within a guess ("B").
 * For example, given secret 1325 and a guess 1234,
 * the result is "1A2B".
 * @param secret the secret generated in the beginning of the game
 * @param guess the guess made by the player
 * @returns {string}
 */
export function getHint(secret, guess) {
    if (secret.length !== guess.length
        || secret.length !== 4) {
        throw "Bad secret and/or guess";
    }
    let numA = 0, numB = 0;
    for (let i = 0; i < 4; i++) {
        if (secret[i] === guess[i]) {
            numA++;
        } else if (secret.includes(guess[i])) {
            numB++;
        }
    }
    return numA + "A" + numB + "B";
}


/**
 * Returns if the game has ended.
 * @param status the status of the game
 */
export function hasGameEnded(status) {
    return (status === "You won!" || status === "You lost!");
}