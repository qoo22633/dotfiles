/**
 * Claude Code のステータスライン（home/.claude/statusline-command.sh）と同じ見た目のフッター。
 *
 *   📂 ~/repo │ 🌿 main +12 -3
 *   🧠 ███░░░░░░░░░░░░ 21% │ 💪 (router) auto → deepseek-v4-pro (high)
 *   🕐 █░░░░░░░░░░░░░░ 7% resets in 2h 35m │ 📅 ░░░░░░░░░░░░░░░ 1% resets in 4d 6h
 *   （extension のステータス。billion-context-pi など）
 *
 * `→` の後ろは、virtual model（quota-router.ts）を選んでいるときに直近の応答を返したモデル。
 */

import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";
import { type CodexRateLimits, type RateLimitWindow, currentPercent, parseCodexRateLimitsEvent, readCachedRateLimits } from "./lib/codex-rate-limits.ts";

const BAR_CELLS = 15;
const WARNING_PERCENT = 70;
const ERROR_PERCENT = 90;
const GIT_TIMEOUT_MS = 3000;

type GitChanges = { insertions: number; deletions: number };

function renderBar(percent: number): string {
	const filled = Math.min(BAR_CELLS, Math.round((percent * BAR_CELLS) / 100));
	return "█".repeat(filled) + "░".repeat(BAR_CELLS - filled);
}

function renderGauge(percent: number | null, theme: Theme): string {
	if (percent === null) return `${"░".repeat(BAR_CELLS)} -`;
	const gauge = `${renderBar(percent)} ${Math.round(percent)}%`;
	if (percent > ERROR_PERCENT) return theme.fg("error", gauge);
	if (percent > WARNING_PERCENT) return theme.fg("warning", gauge);
	return gauge;
}

function renderRateLimit(window: RateLimitWindow | null, now: number, theme: Theme): string {
	const gauge = renderGauge(currentPercent(window, now), theme);
	if (!window || window.resetAt <= now) return gauge;
	const totalMinutes = Math.ceil((window.resetAt - now) / 60);
	const days = Math.floor(totalMinutes / 1440);
	const hours = Math.floor((totalMinutes % 1440) / 60);
	const minutes = totalMinutes % 60;
	const remaining = days > 0 ? `${days}d ${hours}h` : hours > 0 ? `${hours}h ${minutes}m` : `${minutes}m`;
	return `${gauge} ${theme.fg("dim", `resets in ${remaining}`)}`;
}

function shortenHome(cwd: string): string {
	const home = process.env.HOME;
	if (!home || !cwd.startsWith(home)) return cwd;
	return `~${cwd.slice(home.length)}`;
}

function parseNumstat(stdout: string): GitChanges {
	let insertions = 0;
	let deletions = 0;
	for (const line of stdout.split("\n")) {
		const [added, removed] = line.split("\t");
		// バイナリファイルは "-" になるので数えない
		if (/^\d+$/.test(added ?? "")) insertions += Number(added);
		if (/^\d+$/.test(removed ?? "")) deletions += Number(removed);
	}
	return { insertions, deletions };
}

function formatGitChanges({ insertions, deletions }: GitChanges): string {
	const parts: string[] = [];
	if (insertions > 0) parts.push(`+${insertions}`);
	if (deletions > 0) parts.push(`-${deletions}`);
	return parts.length > 0 ? ` ${parts.join(" ")}` : "";
}

function nowSeconds(): number {
	return Math.floor(Date.now() / 1000);
}

/** 直近の応答を返した実際のモデル（virtual model を選んでいるときの振り分け先） */
function findLatestRespondingModel(ctx: ExtensionContext): string | null {
	const entries = ctx.sessionManager.getBranch();
	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];
		if (entry?.type === "message" && entry.message.role === "assistant") return entry.message.model;
	}
	return null;
}

export default function (pi: ExtensionAPI) {
	let rateLimits: CodexRateLimits | null = null;
	let respondingModel: string | null = null;
	let gitChanges: GitChanges = { insertions: 0, deletions: 0 };
	let requestRender = () => {};

	async function refreshGitChanges(cwd: string): Promise<void> {
		const options = { cwd, timeout: GIT_TIMEOUT_MS };
		const [unstaged, staged] = await Promise.all([
			pi.exec("git", ["diff", "--numstat"], options),
			pi.exec("git", ["diff", "--cached", "--numstat"], options),
		]);
		// git リポジトリの外では失敗するので、差分なしとして扱う
		gitChanges = unstaged.code === 0 && staged.code === 0
			? parseNumstat(`${unstaged.stdout}\n${staged.stdout}`)
			: { insertions: 0, deletions: 0 };
		requestRender();
	}

	function installFooter(ctx: ExtensionContext): void {
		ctx.ui.setFooter((tui, theme, footerData) => {
			requestRender = () => tui.requestRender();
			const unsubscribe = footerData.onBranchChange(() => tui.requestRender());
			const timer = setInterval(() => tui.requestRender(), 60_000);
			timer.unref();

			return {
				dispose() {
					clearInterval(timer);
					unsubscribe();
					requestRender = () => {};
				},
				invalidate() {},
				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const location = branch
						? `📂 ${shortenHome(ctx.cwd)} │ 🌿 ${branch}${formatGitChanges(gitChanges)}`
						: `📂 ${shortenHome(ctx.cwd)}`;

					const model = ctx.model;
					const provider = footerData.getAvailableProviderCount() > 1 && model ? `(${model.provider}) ` : "";
					const thinking = model?.reasoning ? ` (${ctx.thinkingLevel})` : "";
					const routed = model && respondingModel && respondingModel !== model.id ? ` → ${respondingModel}` : "";
					const modelLabel = `💪 ${provider}${model?.id ?? "no-model"}${routed}${thinking}`;
					const context = `🧠 ${renderGauge(ctx.getContextUsage()?.percent ?? null, theme)}`;

					const now = nowSeconds();
					const fiveHour = renderRateLimit(rateLimits?.fiveHour ?? null, now, theme);
					const weekly = renderRateLimit(rateLimits?.weekly ?? null, now, theme);
					const limits = `🕐 ${fiveHour} │ 📅 ${weekly}`;

					const lines = [location, `${context} │ ${modelLabel}`, limits];

					const statuses = [...footerData.getExtensionStatuses().entries()]
						.sort(([a], [b]) => a.localeCompare(b))
						.map(([, text]) => text.replace(/\s+/g, " ").trim());
					if (statuses.length > 0) lines.push(statuses.join(" "));

					return lines.map((line) => truncateToWidth(line, width, "..."));
				},
			};
		});
	}

	pi.on("session_start", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		// 起動直後は Codex からの通知がまだ無いので、前回までの値（別の pi が書いたもの）を出しておく
		rateLimits = readCachedRateLimits();
		respondingModel = findLatestRespondingModel(ctx);
		installFooter(ctx);
		await refreshGitChanges(ctx.cwd);
	});

	pi.on("turn_end", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		respondingModel = findLatestRespondingModel(ctx);
		await refreshGitChanges(ctx.cwd);
	});

	pi.on("provider_stream_event", (event) => {
		const parsed = parseCodexRateLimitsEvent(event.data);
		if (!parsed) return;
		rateLimits = parsed;
		requestRender();
	});
}
