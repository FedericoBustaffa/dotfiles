/**
 * md-log — mirror the session to a markdown file for comfortable reading.
 *
 * Designed for long teaching/learning sessions where the terminal is hard on
 * the eyes and markdown/math/code don't render. The linked .md file is meant
 * to be viewed rendered (e.g. in Obsidian), so assistant text with $...$ math,
 * code blocks, and markdown all render natively — no rendering work here.
 *
 * Captures only reading-relevant content:
 *   - user prompts
 *   - assistant text (lesson prose)
 *   - study_answer / quiz / ask_user_question Q&A blocks
 * Other tools (bash, read, write, edit, ...) are omitted.
 *
 * Quiz/ask questions are written BEFORE the user answers (on tool_call), so the
 * reader sees the question appear live; the answer + feedback are appended on
 * tool_result. The question block NEVER contains the correct answer or
 * explanation (the user reads this file live).
 *
 * Commands:
 *   /md-log <filepath>  — Link a markdown file and backfill the session.
 *   /md-unlog           — Stop logging.
 *
 * Live output is append-only. Linking backfills the active branch; replacing
 * nonempty content requires explicit confirmation. Use a dedicated transcript,
 * never a learner note or an agent-maintained curated session board.
 */

import { withFileMutationQueue, type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";

const QA_TOOLS = new Set(["study_answer", "quiz", "ask_user_question"]);
// Legacy tutor announcements are workflow state, not study material. Match only
// complete standalone lines; never remove explanations that mention a phase.
const STUDY_STATUS_LINES = new Set([
	"Probing started — questions only; feedback comes after probing.",
	"Probing complete — planning begins.",
	"Plan proposed — awaiting your go-ahead.",
	"Plan approved — learning session begins.",
	"Diagnostic re-probe started — questions only.",
	"Diagnostic re-probe complete — learning resumes.",
]);

export default function mdLog(pi: ExtensionAPI) {
	let logFile: string | null = null;

	const qaInputs = new Map<string, any>();
	const loggedQuizQuestion = new Set<string>();

	// Restore only links on the active branch, including after tree navigation.
	function restoreLink(ctx: any) {
		let lastLinkData: { file: string | null } | undefined;
		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type === "custom" && entry.customType === "md-log") {
				lastLinkData = entry.data as { file: string | null } | undefined;
			}
		}
		logFile = lastLinkData?.file ?? null;
		qaInputs.clear();
		loggedQuizQuestion.clear();
		const theme = ctx.ui.theme;
		ctx.ui.setStatus("md-log", logFile
			? theme.fg("accent", "🗒 ") + theme.fg("dim", path.basename(logFile))
			: undefined);
	}
	pi.on("session_start", async (_event, ctx) => restoreLink(ctx));
	pi.on("session_tree", async (_event, ctx) => restoreLink(ctx));

	// --- Serialization: events can fire close together; keep appends ordered ---

	let writeLock: Promise<void> = Promise.resolve();
	function withLock<T>(fn: () => T | Promise<T>): Promise<T> {
		const prev = writeLock;
		let release: () => void;
		writeLock = new Promise<void>((r) => {
			release = r;
		});
		return prev.then(fn).finally(() => release!());
	}

	async function appendToFile(text: string): Promise<void> {
		const target = logFile;
		if (!target) return;
		await withFileMutationQueue(target, async () => {
			// Respect an externally deleted transcript; do not recreate it.
			if (!fs.existsSync(target)) return;
			const prefix = fs.statSync(target).size > 0 ? "\n\n" : "";
			fs.appendFileSync(target, prefix + text + "\n", "utf-8");
		});
	}

	// --- Formatting ---

	function callout(type: string, title: string, bodyLines: string[]): string {
		const lines = [`> [!${type}] ${title}`];
		for (const line of bodyLines.flatMap((text) => text.split("\n"))) {
			lines.push(line.length === 0 ? ">" : `> ${line}`);
		}
		return lines.join("\n");
	}

	function userBlock(text: string): string {
		return `> [!quote] YOU\n\n${text}`;
	}

	// Injected skill declarations are context, not readable transcript content.
	function stripSkillBlocks(text: string): string {
		return text.replace(/<skill\b[^>]*>[\s\S]*?<\/skill>/g, "").trim();
	}

	function assistantBlock(text: string): string {
		let fence: string | undefined;
		const lines = text.split("\n").filter((line) => {
			const marker = /^ {0,3}(`{3,}|~{3,})/.exec(line);
			if (fence) {
				if (marker && marker[1][0] === fence[0] && marker[1].length >= fence.length
					&& !line.slice(marker[0].length).trim()) fence = undefined;
				return true;
			}
			if (marker) {
				fence = marker[1];
				return true;
			}
			if (/^(?: {4}|\t)/.test(line)) return true; // Preserve indented code too.
			const plain = line.trim().replace(/^\*\*(.*)\*\*$/, "$1");
			return !STUDY_STATUS_LINES.has(plain);
		});
		const cleaned = lines.join("\n").trim();
		return cleaned ? `> [!abstract] PI\n\n${cleaned}` : "";
	}

	function optionsList(options: Array<{ label: string }>): string[] {
		return options.map((o, i) => `${i + 1}. ${o.label}`);
	}

	function questionCallout(label: string, question: string, context: string | undefined, options: Array<{ label: string }>): string {
		const body: string[] = [];
		for (const line of question.split("\n")) body.push(line);
		if (context) {
			body.push("");
			for (const line of context.split("\n")) body.push(line);
		}
		if (options.length > 0) {
			body.push("");
			body.push(...optionsList(options));
		}
		return callout("question", label, body);
	}

	function answerCalloutQuiz(details: any): string {
		const status = details?.status;
		if (status === "cancelled") {
			return callout("warning", "Quiz — cancelled", ["(user skipped)"]);
		}
		if (status === "unavailable") {
			return callout("warning", "Quiz — unavailable", [details?.message || ""]);
		}
		// "I don't know" is neither correct nor incorrect — it's a distinct signal,
		// so it never renders as a red ✗.
		const dontKnow = details?.dontKnow === true;
		const correct = details?.correct === true;
		const type = dontKnow ? "question" : correct ? "success" : "failure";
		const title = dontKnow
			? "Quiz — I don't know"
			: correct
				? "Quiz — correct ✓"
				: "Quiz — incorrect ✗";
		const body: string[] = [];

		if (dontKnow) {
			body.push("Your answer: I don't know");
		} else {
			const answers: any[] = details?.answers || [];
			const sel = answers.map((a) => `${a.index}. ${a.label}`).join(", ") || "(none)";
			body.push(`Your answer: ${sel}`);
		}

		const correctIndices: number[] = details?.correctIndices || [];
		const correctStr = correctIndices.map((i) => `${i}`).join(", ");
		body.push(`Correct answer: ${correctStr}`);

		// Optional free-text note the user typed in the always-present note field.
		// Only present (in details) when non-empty, so no guard for empty strings.
		if (details?.note) {
			body.push("");
			const noteLines = String(details.note).split("\n");
			body.push(`Note: ${noteLines[0]}`);
			for (let i = 1; i < noteLines.length; i++) body.push(noteLines[i]);
		}

		if (details?.explanation) {
			body.push("");
			for (const line of String(details.explanation).split("\n")) body.push(line);
		}
		return callout(type, title, body);
	}

	function answerCalloutStudy(details: any): string {
		if (details?.status !== "answered") {
			return callout("note", "Response — unanswered", [
				details?.status === "cancelled" ? "Selection cancelled; no answer recorded."
					: "Answer menu unavailable; no answer recorded.",
			]);
		}
		const body = [`Choice: ${details.choice ?? ""} — ${details.answer ?? ""}`];
		if (details.explanation) {
			body.push("", "Learner reasoning:", ...String(details.explanation).split("\n"));
		}
		if (details.explanationTruncated) body.push("", "Reasoning was truncated by the answer tool.");
		return callout("note", "Answer", body);
	}

	function answerBlock(toolName: string, details: any): string {
		return toolName === "study_answer" ? answerCalloutStudy(details)
			: toolName === "quiz" ? answerCalloutQuiz(details) : answerCalloutAsk(details);
	}

	function answerCalloutAsk(details: any): string {
		const status = details?.status;
		if (status === "cancelled") {
			return callout("warning", "Question — cancelled", ["(user skipped)"]);
		}
		if (status === "unavailable") {
			return callout("warning", "Question — unavailable", [details?.message || ""]);
		}
		const answers: any[] = details?.answers || [];
		const body: string[] = answers.map((a) => {
			if (a.type === "other") return `Other: ${a.label}`;
			if (a.type === "text") return a.label;
			return `${a.index}. ${a.label}`;
		});
		if (body.length === 0) body.push("(no answer)");
		return callout("example", "Answer", body);
	}

	// --- Event handlers ---

	pi.on("message_end", async (event, _ctx) => {
		if (!logFile) return;
		const msg = event.message;
		if (!msg || !("role" in msg)) return;

		if (msg.role === "user") {
			const text = typeof msg.content === "string"
				? msg.content
				: Array.isArray(msg.content)
					? msg.content.filter((c: any) => c.type === "text").map((c: any) => c.text).join("\n")
					: "";
			const trimmed = stripSkillBlocks(text.trim());
			if (!trimmed) return;
			await withLock(() => appendToFile(userBlock(trimmed)));
			return;
		}

		if (msg.role === "assistant") {
			const textParts = (msg.content || [])
				.filter((c: any) => c.type === "text")
				.map((c: any) => (c.text as string).trim())
				.filter((t: string) => t.length > 0);
			if (textParts.length === 0) return;
			const block = assistantBlock(textParts.join("\n\n"));
			if (block) await withLock(() => appendToFile(block));
			return;
		}
		// toolResult messages are handled by the tool_result event (for QA tools).
	});

	// Non-shuffled questions can be logged directly from their call arguments.
	pi.on("tool_call", async (event, _ctx) => {
		if (!logFile || !QA_TOOLS.has(event.toolName)) return;
		const input = event.input as any;
		qaInputs.set(event.toolCallId, input);
		if (event.toolName === "quiz") return; // Wait for the shuffled order.
		if (event.toolName === "study_answer") {
			const body = [String(input.question ?? ""), ""];
			for (const [index, option] of (input.options ?? []).entries()) {
				body.push(`${String.fromCharCode(65 + index)}. ${option}`);
			}
			body.push("? — I don't know");
			await withLock(() => appendToFile(callout("question", "Question", body)));
			return;
		}
		const block = questionCallout("Question", input.question || "", input.details?.trim() || undefined,
			Array.isArray(input.options) ? input.options : []);
		await withLock(() => appendToFile(block));
	});

	// tool_execution_update has no call args: pair its displayed order with the
	// input captured at tool_call, not a nonexistent event.args field.
	pi.on("tool_execution_update", async (event, _ctx) => {
		if (!logFile || event.toolName !== "quiz") return;
		if (loggedQuizQuestion.has(event.toolCallId)) return;
		const shuffled = (event.partialResult?.details as {
			options?: Array<{ index: number; label: string }>;
		} | undefined)?.options;
		if (!shuffled?.length) return;
		loggedQuizQuestion.add(event.toolCallId);
		const input = qaInputs.get(event.toolCallId) ?? {};
		const block = questionCallout("Quiz", input.question || "", input.details?.trim() || undefined,
			shuffled.map((o) => ({ label: o.label })));
		await withLock(() => appendToFile(block));
	});

	pi.on("tool_result", async (event, _ctx) => {
		if (!logFile || !QA_TOOLS.has(event.toolName)) return;
		await withLock(() => appendToFile(answerBlock(event.toolName, event.details)));
		qaInputs.delete(event.toolCallId);
		loggedQuizQuestion.delete(event.toolCallId);
	});

	// --- Commands ---

	pi.registerCommand("md-log", {
		description: "Mirror the session to a markdown file (backfills history)",
		handler: async (args, ctx: any) => {
			const filepath = args.trim();
			if (!filepath) {
				ctx.ui.notify("Usage: /md-log <filepath>", "warning");
				return;
			}
			if (typeof ctx.isIdle === "function" && !ctx.isIdle()) {
				ctx.ui.notify("Wait for the agent to finish before linking.", "warning");
				return;
			}

			const requested = path.isAbsolute(filepath) ? filepath : path.resolve(ctx.cwd, filepath);
			if (!/\.(md|markdown)$/i.test(requested)) {
				ctx.ui.notify("Choose a dedicated Markdown transcript file, not another file type.", "error");
				return;
			}
			const resolved = fs.existsSync(requested) ? fs.realpathSync(requested) : requested;

			// The file must already exist — /md-log links into an existing note,
			// it never creates one. This avoids silently scattering new files
			// (and parent directories) around the vault from a typo'd path.
			if (!fs.existsSync(resolved)) {
				ctx.ui.notify(`File does not exist: ${resolved}`, "error");
				return;
			}
			if (!fs.statSync(resolved).isFile()) {
				ctx.ui.notify(`Not a file: ${resolved}`, "error");
				return;
			}

			if (fs.statSync(resolved).size > 0) {
				const approved = ctx.hasUI && await ctx.ui.confirm(
					"Replace transcript contents?",
					`${resolved}\n\nBackfill replaces this file with the active-branch transcript. Do not use personal notes or a curated session board. Continue?`,
				);
				if (!approved) return;
			}

			let written: number;
			try {
				written = await withLock(() => backfill(ctx, resolved));
			} catch (error) {
				ctx.ui.notify(`Could not backfill transcript: ${String(error)}`, "error");
				return;
			}
			logFile = resolved;
			pi.appendEntry("md-log", { file: resolved });

			const theme = ctx.ui.theme;
			ctx.ui.setStatus(
				"md-log",
				theme.fg("accent", "🗒 ") + theme.fg("dim", path.basename(resolved)),
			);
			ctx.ui.notify(`Linked: ${resolved} (${written} entries backfilled)`, "success");
		},
	});

	pi.registerCommand("md-unlog", {
		description: "Stop mirroring the session to a markdown file",
		handler: async (_args, ctx) => {
			if (!logFile) {
				ctx.ui.notify("No file linked", "warning");
				return;
			}
			const name = path.basename(logFile);
			logFile = null;
			pi.appendEntry("md-log", { file: null });
			ctx.ui.setStatus("md-log", undefined);
			ctx.ui.notify(`Unlinked: ${name}`, "info");
		},
	});

	// --- Backfill ---

	async function backfill(ctx: any, target: string): Promise<number> {
		const chain: any[] = ctx.sessionManager.getBranch();
		if (chain.length === 0) return 0;

		// Track tool-call args from assistant messages so we can pair with results.
		const toolCallArgs = new Map<string, { name: string; args: any }>();

		const blocks: string[] = [];
		let count = 0;
		for (const entry of chain) {
			if (entry.type !== "message") continue;
			const msg = entry.message;
			if (!msg || !("role" in msg)) continue;
			count++;

			if (msg.role === "user") {
				const text = typeof msg.content === "string"
					? msg.content
					: Array.isArray(msg.content)
						? msg.content.filter((c: any) => c.type === "text").map((c: any) => c.text).join("\n")
						: "";
				const trimmed = stripSkillBlocks(text.trim());
				if (trimmed) blocks.push(userBlock(trimmed));
				continue;
			}

			if (msg.role === "assistant") {
				// Index tool calls for later pairing.
				for (const c of msg.content || []) {
					if (c.type === "toolCall" && QA_TOOLS.has(c.name)) {
						toolCallArgs.set(c.id, { name: c.name, args: c.arguments });
					}
				}
				const textParts = (msg.content || [])
					.filter((c: any) => c.type === "text")
					.map((c: any) => (c.text as string).trim())
					.filter((t: string) => t.length > 0);
				const block = assistantBlock(textParts.join("\n\n"));
				if (block) blocks.push(block);
				continue;
			}

			if (msg.role === "toolResult") {
				if (!QA_TOOLS.has(msg.toolName)) continue;
				const tc = toolCallArgs.get(msg.toolCallId);
				// Question block. For quiz, use the persisted result's `details.options`
				// — the TRUE post-shuffle display order the user actually saw — rather
				// than the original tool-call args, which are the pre-shuffle author
				// order and can mismatch what's on screen. ask_user_question never
				// shuffles, so its tool-call args are already the true order.
				if (tc) {
					const a = tc.args || {};
					const label = tc.name === "quiz" ? "Quiz" : "Question";
					const shuffled = msg.toolName === "quiz"
						? (msg.details?.options as Array<{ index: number; label: string }> | undefined)
						: undefined;
					const options = shuffled && shuffled.length > 0
						? shuffled.map((o) => ({ label: o.label }))
						: (Array.isArray(a.options) ? a.options : []);
					if (tc.name === "study_answer") {
						const body = [String(a.question ?? ""), ""];
						for (const [index, option] of (a.options ?? []).entries()) {
							body.push(`${String.fromCharCode(65 + index)}. ${option}`);
						}
						body.push("? — I don't know");
						blocks.push(callout("question", "Question", body));
					} else {
						blocks.push(questionCallout(label, a.question || "", a.details?.trim() || undefined, options));
					}
				}
				blocks.push(answerBlock(msg.toolName, msg.details));
				continue;
			}
		}

		if (blocks.length > 0) {
			await withFileMutationQueue(target, async () => {
				fs.writeFileSync(target, blocks.join("\n\n") + "\n", "utf-8");
			});
		}
		return count;
	}
}
