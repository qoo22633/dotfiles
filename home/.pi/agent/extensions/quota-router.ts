/**
 * ChatGPT サブスク（Codex）の利用上限が近づいたら DeepSeek に切り替える virtual model。
 *
 *   router/auto        普段は gpt-6.1-sol、上限が近いときは deepseek-v4-pro（メインの作業）
 *   router/auto-light  普段は gpt-6-luna、上限が近いときは deepseek-flash（サブエージェントの雑用）
 *
 * 利用上限のエラーは pi が再試行しないため、エラーを見てから切り替えることはできない。
 * そのため、しきい値を超えた時点で先に切り替える。
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isNearLimit, parseCodexRateLimitsEvent, readCachedRateLimits, writeCachedRateLimits } from "./lib/codex-rate-limits.ts";

const ROUTER_PROVIDER = "router";
const SWITCH_THRESHOLD_PERCENT = 90;
const THINKING_LEVELS = ["low", "medium", "high", "xhigh"] as const;

type ModelRef = { provider: string; id: string };
type QuotaRoute = { name: string; primary: ModelRef; fallback: ModelRef };

const QUOTA_ROUTES = {
	auto: {
		name: "Auto (gpt-6.1-sol → deepseek-v4-pro)",
		primary: { provider: "openai-codex", id: "gpt-6.1-sol" },
		fallback: { provider: "deepseek", id: "deepseek-v4-pro" },
	},
	"auto-light": {
		name: "Auto light (gpt-6-luna → deepseek-flash)",
		primary: { provider: "openai-codex", id: "gpt-6-luna" },
		fallback: { provider: "deepseek", id: "deepseek-flash" },
	},
} satisfies Record<string, QuotaRoute>;

function nowSeconds(): number {
	return Math.floor(Date.now() / 1000);
}

export default function (pi: ExtensionAPI) {
	for (const [id, route] of Object.entries(QUOTA_ROUTES)) {
		pi.registerVirtualModel({
			provider: ROUTER_PROVIDER,
			id,
			name: route.name,
			thinkingLevels: THINKING_LEVELS,
			route(request, ctx) {
				// ツール結果の続きや再試行は同じモデルのまま続け、プロンプトキャッシュを活かす
				const sticky = request.reason === "retry" ? request.failed : request.previous;
				if (request.reason !== "user" && sticky) {
					return { model: sticky.model, thinkingLevel: sticky.thinkingLevel ?? request.thinkingLevel };
				}

				const target = isNearLimit(readCachedRateLimits(), nowSeconds(), SWITCH_THRESHOLD_PERCENT)
					? route.fallback
					: route.primary;
				const model = ctx.modelRegistry.find(target.provider, target.id);
				if (!model) throw new Error(`${target.provider}/${target.id} が見つからない（ログインしているか確認する）`);
				return { model, thinkingLevel: request.thinkingLevel };
			},
		});
	}

	pi.on("provider_stream_event", (event) => {
		const limits = parseCodexRateLimitsEvent(event.data);
		if (limits) writeCachedRateLimits(limits);
	});
}
