"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupSocketAuth = setupSocketAuth;
const jose_1 = require("jose");
function setupSocketAuth(io, secret) {
    io.use(async (socket, next) => {
        const token = socket.handshake.auth?.token;
        if (!token)
            return next(new Error('auth_required'));
        try {
            const { payload } = await (0, jose_1.jwtVerify)(token, secret);
            socket.data.userId = payload.sub;
            socket.data.username = payload.username;
            next();
        }
        catch {
            next(new Error('invalid_token'));
        }
    });
}
