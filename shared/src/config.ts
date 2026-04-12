const origin = process.env.FRONTEND_URL;
if (!origin) {
    console.warn('[shared] FRONTEND_URL is not set — CORS will block all cross-origin requests');
}

export const corsConfig = {
    origin: origin || false,
    methods: ['GET', 'POST'],
    credentials: true,
};
