/**
 * Claude Code のステータスライン（home/.claude/statusline-command.sh）と同じ見た目のフッター。
 *
 *   📂 ~/repo │ 🌿 main +12 -3
 *   🧠 ███░░░░░░░░░░░░ 21% │ 💪 (openai-codex) gpt-6.1-sol (high)
 *   🕐 █░░░░░░░░░░░░░░ 7% │ 📅 ░░░░░░░░░░░░░░░ 1%
 *   （extension のステータス。billion-context-pi など）
 */

import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth } from "@earendil-works/pi-tui";

const BAR_CELLS = 15;
const WARNING_PERCENT = 70;
const ERROR_PERCENT = 90;
const GIT_TIMEOUT_MS = 3000;

// Codex は HTTP ヘッダーではなく WebSocket のストリームの中でこのイベントとして利用上限を送ってくる
const CODEX_RATE_LIMITS_EVENT = "codex.rate_limits";

type RateLimits = { fiveHourPercent: number | null; weeklyPercent: number | null };
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

function isRecord(value: unknown): value is Record<string, unknown> {
	return typeof value === "object" && value !== null;
}

function toPercent(window: unknown): number | null {
	if (!isRecord(window)) return null;
	return typeof window.used_percent === "number" ? window.used_percent : null;
}

function parseCodexRateLimits(data: unknown): RateLimits | null {
	if (!isRecord(data) || data.type !== CODEX_RATE_LIMITS_EVENT) return null;
	const limits = data.rate_limits;
	if (!isRecord(limits)) return null;
	return {
		fiveHourPercent: toPercent(limits.primary),
		weeklyPercent: toPercent(limits.secondary),
	};
}

export default function (pi: ExtensionAPI) {
	let rateLimits: RateLimits = { fiveHourPercent: null, weeklyPercent: null };
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

			return {
				dispose: unsubscribe,
				invalidate() {},
				render(width: number): string[] {
					const branch = footerData.getGitBranch();
					const location = branch
						? `📂 ${shortenHome(ctx.cwd)} │ 🌿 ${branch}${formatGitChanges(gitChanges)}`
						: `📂 ${shortenHome(ctx.cwd)}`;

					const model = ctx.model;
					const provider = footerData.getAvailableProviderCount() > 1 && model ? `(${model.provider}) ` : "";
					const thinking = model?.reasoning ? ` (${ctx.thinkingLevel})` : "";
					const modelLabel = `💪 ${provider}${model?.id ?? "no-model"}${thinking}`;
					const context = `🧠 ${renderGauge(ctx.getContextUsage()?.percent ?? null, theme)}`;

					const limits = `🕐 ${renderGauge(rateLimits.fiveHourPercent, theme)} │ 📅 ${renderGauge(rateLimits.weeklyPercent, theme)}`;

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
		installFooter(ctx);
		await refreshGitChanges(ctx.cwd);
	});

	pi.on("turn_end", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		await refreshGitChanges(ctx.cwd);
	});

	pi.on("provider_stream_event", (event) => {
		const parsed = parseCodexRateLimits(event.data);
		if (!parsed) return;
		rateLimits = parsed;
		requestRender();
	});
}
