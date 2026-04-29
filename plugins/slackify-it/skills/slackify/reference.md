# Slackify: research grounding and prior art

Background material for the slackify skill. SKILL.md contains the operational rules; this file explains *why* those rules exist and credits the prior art they're built on.

---

## Why a separate skill from `humanize-it`

The two plugins look adjacent but have *opposing* rules in several places:

| Rule | humanize-it | slackify-it |
|---|---|---|
| Emojis | strip in professional contexts | preserve when source had them; add sparingly when they fit |
| Forbidden first words ("Great", "Sure") | always strip | "Hey", "FYI", "Heads up" are fine openers |
| Bullet lists | prefer prose; flag bullet bloat | bullets are a Slack-native scanning aid, OK to use |
| Short messages | substance-check void if content-free | a 1-line ping ("can we move standup?") is valid output |
| Bold formatting | don't introduce | `*bold lead:*` is a recommended Slack pattern for announcements |

Bundling them as two skills under one plugin would risk one rule contradicting the other on the same input. Separate plugins keep the mental models clean and let you compose: humanize-it first to strip slop, then slackify-it to format for chat.

---

## Length data (where the targets in SKILL.md come from)

Empirical guidance from the [Slack Message Best Practices](https://lettercounter.org/blog/slack-message-length-best-practices/) analysis:

- **Quick:** 50–150 chars
- **Standard:** 150–300 chars
- **Detailed:** 300–500 chars
- **>500 chars:** thread, canvas, or doc

**The "Show more" collapse** happens around the **200-character mark.** This is the single most actionable threshold — front-load critical info in the first ~200 chars or readers may not expand.

**Hard limits** (from Slack's own docs):
- 4,000 chars per message recommended max
- 40,000 chars technical max
- 8,000 chars in DMs
- 3,000 chars per Block Kit section text
- 100 chars for status, 250 for channel topic/description

---

## Slack mrkdwn reference

The authoritative spec lives at [docs.slack.dev/messaging/formatting-message-text/](https://docs.slack.dev/messaging/formatting-message-text/). Key facts SKILL.md depends on:

- **Bold** is `*single asterisks*`, NOT standard markdown `**double**`. This is the most-violated rule in copy-pasted markdown.
- **Italic** is `_underscores_`. `*asterisks*` are bold, not italic — opposite of standard markdown.
- **Strikethrough** is `~tildes~` (single, not double).
- **Lists** have no native syntax — use `-` or `•` with newlines. Numbered lists work as `1. item`.
- **Headers** (`#`/`##`) only render when "Format messages with markup" is enabled and only level 1–2. Safer to avoid headers entirely.
- **Links** in mrkdwn are `<url|text>` — angle brackets, pipe-separated. Standard markdown `[text](url)` only works in markup mode.
- **Tables, colors, nested formatting** are unsupported. Convert tables to lists; strip color directives; pick one style per span.
- **API escaping:** `&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;` matter at the API level, not in the chat UI.

---

## Mention semantics

From the [Slack messaging docs](https://docs.slack.dev/messaging/):

| Mention | Notification scope |
|---|---|
| `<@USER_ID>` | one user |
| `<#CHANNEL_ID>` | reference only (no notification) |
| `<!subteam^GROUP_ID>` | all members of a user group |
| `<!here>` | active members of the current channel |
| `<!channel>` | all members of the current channel |
| `<!everyone>` | all members of #general |

The broadcast triumvirate (`@here`, `@channel`, `@everyone`) is the most-abused Slack feature. Per Slack's own conventions: use only when the message genuinely needs every recipient's attention right now (outage, vote, deadline). The skill defaults to stripping casual broadcasts ("Hey @everyone!" → "Hey").

---

## Prior art

### Deterministic markdown→mrkdwn converters

These libraries do the *mechanical* conversion (`**bold**` → `*bold*`, `[text](url)` → `<url|text>`, etc.). They don't handle tone, length, or restructuring — but they're battle-tested for the syntax mapping.

- [`jsarafajr/slackify-markdown`](https://github.com/jsarafajr/slackify-markdown) — the canonical JavaScript implementation, based on Unified/Remark. The skill's syntax conversion table mirrors this lib's behavior.
- [`thesmallstar/slackify-markdown-python`](https://github.com/thesmallstar/slackify-markdown-python) — Python port. Available as `pip install slackify-markdown`.
- [`ywkim/slackstyler`](https://github.com/ywkim/slackstyler) — alternative Python implementation built on `mistune`.
- [`thundergolfer/slackify-markdown`](https://github.com/thundergolfer/slackify-markdown) — Rust port.
- Slack Markdown Converter — GitHub Action.

When precision matters (CI pipelines, automated bot output), invoke one of these libs directly rather than rely on an LLM rewrite. The slackify-it skill is for the cases that require *judgment* — trimming, tone, restructuring — not just syntax mapping.

### LLM-based message generators

- **[QuillBot AI Slack Message Generator](https://quillbot.com/ai-writing-tools/ai-slack-message-generator)** — commercial. Generates from a description rather than rewriting. Tends toward generic placeholders (`[Manager Name]`); slackify-it deliberately rejects this pattern.
- **[Ludwig Henne's GPT prompt + free Slack app](https://medium.com/@ludwighenne/format-your-slack-messages-with-gpt-free-slack-app-and-the-best-chatgpt-prompt-to-use-f9232bfc451a)** — open prompt the author recommends. Uses single asterisks (we agree), encourages "lots of emojis" (we disagree — restraint per Slack's own guidance), wraps numbers in backticks (we disagree — over-engineers code formatting).
- **Slack's native AI in Canvas** — Slack itself does this transformation natively for Canvas writing. slackify-it is most useful for users who don't have Slack AI access or who draft outside Slack.
- **Bardeen** — workflow tool; summarizes new emails into Slack messages via OpenAI. Different scope (full automation pipeline, not a rewriter).

### Best-practice guides

- [Slack: Designing and formatting messages](https://slack.com/blog/collaboration/designing-and-formatting-messages-in-slack) — Slack's own guidance. Source of the "save formatting effort for high-impact contexts" yellow-flag rule.
- [Wrangle: Slack Markdown Comprehensive Guide](https://www.wrangle.io/post/slack-markdown-a-comprehensive-guide-to-formatting-messages) — third-party cheat sheet, source of the "no tables, no colors, desktop-only markup mode" constraints.
- [Letter Counter: Slack Message Length Best Practices](https://lettercounter.org/blog/slack-message-length-best-practices/) — source of the empirical length targets.

---

## Where slackify-it fits in the ecosystem

- **vs. deterministic converters** — they handle syntax; we handle judgment. Use them in pipelines, use us in chat-style "make this work for Slack."
- **vs. QuillBot / Ludwig prompts** — we're more conservative on emoji and tone changes. We rewrite what's there; we don't invent placeholders or generic structure.
- **vs. Slack's native AI** — we're free, run locally via Claude Code, and give you control over the rules (edit SKILL.md). Slack's Canvas AI is more polished but less transparent and Slack-paid-tier-only.
