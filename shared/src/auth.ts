import { jwtVerify } from 'jose';
import type { Server } from 'socket.io';

export function setupSocketAuth(io: Server, secret: Uint8Array): void {
    io.use(async (socket, next) => {
        const token = socket.handshake.auth?.token as string | undefined;
        if (!token) return next(new Error('auth_required'));
        try {
            const { payload } = await jwtVerify(token, secret);
            socket.data.userId = payload.sub as string;
            socket.data.username = payload.username as string;
            next();
        } catch {
            next(new Error('invalid_token'));
        }
    });
}
