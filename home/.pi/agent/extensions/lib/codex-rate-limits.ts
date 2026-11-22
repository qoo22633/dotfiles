/**
 * ChatGPT サブスク（Codex）の利用上限の読み取りと共有。
 *
 * 利用上限はアカウント全体で共通なので、最新値をキャッシュファイルに書き、
 * 別プロセスで動くサブエージェントや次に起動する pi からも同じ値を読めるようにする。
 */

import { mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join } from "node:path";

// Codex は HTTP ヘッダーではなく WebSocket のストリームの中でこのイベントとして利用上限を送ってくる
const CODEX_RATE_LIMITS_EVENT = "codex.rate_limits";

export type RateLimitWindow = {
	usedPercent: number;
	/** 枠がリセットされる時刻（Unix 秒） */
	resetAt: number;
};

export type CodexRateLimits = {
	fiveHour: RateLimitWindow | null;
	weekly: RateLimitWindow | null;
};

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

function toWindow(value: unknown): RateLimitWindow | null {
	if (!isRecord(value)) return null;
	const { used_percent: usedPercent, reset_at: resetAt } = value;
	if (typeof usedPercent !== "number" || typeof resetAt !== "number") return null;
	return { usedPercent, resetAt };
}

function toCachedWindow(value: unknown): RateLimitWindow | null {
	if (!isRecord(value)) return null;
	const { usedPercent, resetAt } = value;
	if (typeof usedPercent !== "number" || typeof resetAt !== "number") return null;
	return { usedPercent, resetAt };
}

/** provider_stream_event の data が Codex の利用上限イベントなら取り出す */
export function parseCodexRateLimitsEvent(data: unknown): CodexRateLimits | null {
	if (!isRecord(data) || data.type !== CODEX_RATE_LIMITS_EVENT) return null;
	const limits = data.rate_limits;
	if (!isRecord(limits)) return null;
	return { fiveHour: toWindow(limits.primary), weekly: toWindow(limits.secondary) };
}

/** リセット時刻を過ぎた枠は 0% として扱う。値が無ければ null（不明） */
export function currentPercent(window: RateLimitWindow | null, nowSeconds: number): number | null {
	if (!window) return null;
	return window.resetAt > nowSeconds ? window.usedPercent : 0;
}

export function isNearLimit(limits: CodexRateLimits | null, nowSeconds: number, thresholdPercent: number): boolean {
	if (!limits) return false;
	return [limits.fiveHour, limits.weekly].some((window) => (currentPercent(window, nowSeconds) ?? 0) >= thresholdPercent);
}

function cachePath(): string {
	const cacheHome = process.env.XDG_CACHE_HOME || join(homedir(), ".cache");
	return join(cacheHome, "pi", "codex-rate-limits.json");
}

export function readCachedRateLimits(): CodexRateLimits | null {
	let raw: string;
	try {
		raw = readFileSync(cachePath(), "utf8");
	} catch {
		// まだ一度も Codex を使っていない端末ではファイルが無い
		return null;
	}
	try {
		const parsed: unknown = JSON.parse(raw);
		if (!isRecord(parsed)) return null;
		return { fiveHour: toCachedWindow(parsed.fiveHour), weekly: toCachedWindow(parsed.weekly) };
	} catch {
		// 書き込み途中などで壊れていたら、不明として扱う
		return null;
	}
}

export function writeCachedRateLimits(limits: CodexRateLimits): void {
	const path = cachePath();
	mkdirSync(dirname(path), { recursive: true });
	// 複数のプロセスが同時に読むので、書きかけのファイルを読ませないよう rename で置き換える
	const tmpPath = `${path}.${process.pid}.tmp`;
	writeFileSync(tmpPath, JSON.stringify(limits));
	renameSync(tmpPath, path);
}
