"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.corsConfig = void 0;
const origin = process.env.FRONTEND_URL;
if (!origin) {
    console.warn('[shared] FRONTEND_URL is not set — CORS will block all cross-origin requests');
}
exports.corsConfig = {
    origin: origin || false,
    methods: ['GET', 'POST'],
    credentials: true,
};
