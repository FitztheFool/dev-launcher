"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.shuffle = shuffle;
const crypto_1 = require("crypto");
function shuffle(arr) {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i--) {
        const j = (0, crypto_1.randomInt)(0, i + 1);
        [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
}
