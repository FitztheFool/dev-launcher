export interface ScoreEntry {
    userId: string;
    username?: string;
    score: number;
    placement?: number | null;
    abandon?: boolean;
    afk?: boolean;
    [key: string]: unknown;
}

export interface BotEntry {
    username?: string;
    score: number;
    placement?: number | null;
}

export async function saveAttempts(
    gameType: string,
    gameId: string,
    scores: ScoreEntry[],
    vsBot = false,
    bots?: BotEntry[],
): Promise<void> {
    const frontendUrl = process.env.FRONTEND_URL;
    const secret = process.env.INTERNAL_API_KEY;
    if (!frontendUrl || !secret) return;

    const humanScores = scores.filter(s => !s.userId.startsWith('bot-'));
    if (humanScores.length === 0) return;

    const resolvedBots = bots ?? scores
        .filter(s => s.userId.startsWith('bot-'))
        .map((s, i) => ({ username: s.username ?? `Bot ${i + 1}`, score: s.score, placement: s.placement ?? null }));

    try {
        const res = await fetch(`${frontendUrl}/api/attempts`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${secret}` },
            body: JSON.stringify({
                gameType,
                gameId,
                vsBot,
                bots: resolvedBots.length > 0 ? resolvedBots : undefined,
                scores: humanScores,
            }),
        });
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        console.log(`[${gameType}] scores saved for ${gameId}`);
    } catch (err) {
        console.error(`[${gameType}] saveAttempts error:`, err);
    }
}
