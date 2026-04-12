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
export declare function saveAttempts(gameType: string, gameId: string, scores: ScoreEntry[], vsBot?: boolean, bots?: BotEntry[]): Promise<void>;
