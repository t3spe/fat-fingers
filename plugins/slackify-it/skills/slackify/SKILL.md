---
name: slackify
description: Rewrite text into a Slack-appropriate message. Use when the user asks to "slackify," "slackify it," "make it Slack-appropriate," "format for Slack," "post this to Slack," "send this in Slack," "convert to Slack message," or pastes content (an email, a writeup, an AI response, a long-form note) and asks to make it suitable for posting in a Slack channel or DM. Handles markdown-flavor conversion (`**bold**` → `*bold*`, etc.), strips email scaffolding (greetings, sign-offs), trims length for chat context, and adjusts tone toward casual-professional.
---

Rewrite the input as a Slack message. Return only the rewritten text — no preamble, no "Here's your Slack version," no meta-commentary.

For the research grounding (mrkdwn spec, length data sources, prior-art credits), see `reference.md`.

## What "Slack-appropriate" means

A Slack message is short (1–3 short paragraphs typical, sometimes a single line), casual but not unprofessional, and uses Slack's own markdown subset. It should be readable on a phone in a glance. It should NOT look like a forwarded email or a blog post.

## Pipeline

### 1. Strip email scaffolding

Delete on sight:

- Salutations: "Hi team," "Hey everyone," "Dear all," "Good morning," etc. — *unless* the user explicitly wants one. Slack already shows who you're addressing.
- Sign-offs: "Best regards," "Thanks!", "Cheers,", "Let me know if you have questions," signature blocks, "Sent from my iPhone."
- Subject lines (if a forwarded email).
- "Per my last message," "As discussed," "Following up on..."  Reframe as direct content.

### 2. Convert markdown to Slack flavor

Slack doesn't render standard markdown. Convert:

| Standard | Slack |
|---|---|
| `**bold**` | `*bold*` (single asterisks) |
| `*italic*` or `_italic_` | `_italic_` |
| `~~strike~~` | `~strike~` |
| `## Heading` | (Slack has no headers — use `*Bold line*` for emphasis or just plain text) |
| `[text](url)` | `<url|text>` (Slack-safe; works in all surfaces) |
| `` `code` `` | `` `code` `` (same — backticks) |
| ```` ```block``` ```` | ```` ```block``` ```` (same — triple backticks) |
| `- bullet` or `* bullet` | `• bullet` (or `- bullet`; both render) |
| `1. item` | `1. item` (same) |
| `> quote` | `> quote` (same) |

Strip headers entirely (no `#`, `##`, etc.). Slack only renders `#`/`##` headers when "Format messages with markup" is enabled — they show as literal `#` characters otherwise. If the original used a header to introduce a section, replace with a `*bold first phrase*:` lead or just inline it.

**Slack's hard constraints — convert away if present in source:**
- *No tables.* Convert to a list, an inline summary, or describe the data ("3 of 10 deploys failed; full breakdown in <thread>").
- *No color codes / no styled spans.* Strip any HTML or CSS-style formatting from the source.
- *No HTML.* Slack ignores it. Convert to mrkdwn or plain text.
- *No nested formatting.* `*_bold-italic_*` doesn't render reliably. Pick one.

### 3. Trim for chat context

**Length targets (empirical from Slack length data):**
- *Quick message:* 50–150 chars (single line, fast info).
- *Standard:* 150–300 chars (one short paragraph).
- *Detailed:* 300–500 chars (multi-paragraph but still glanceable).
- *Over 500 chars:* consider thread, canvas, or doc — not a wall in #general.
- *Hard limits:* 4,000 chars per message recommended max (40,000 technical max). 8,000 in DMs.

**The "Show more" rule:** Slack collapses messages around the **200-character mark**. Front-load the most important information in the first ~200 chars so the reader gets the gist without expanding.

- Cut anything that wouldn't survive a glance on a phone screen.
- One idea per paragraph. Use line breaks generously — Slack rewards visual scanning.
- For longer source material, lead with the conclusion (TL;DR style) and let detail follow.
- If the source is over ~6 short paragraphs OR over ~500 chars, prepend `*TL;DR:* <one-line summary>` and consider noting that the rest belongs in a thread reply.

### 4. Tone adjustment

- More casual than email, less casual than texting.
- Contractions are fine and encouraged ("don't", "it's", "we'll").
- Direct phrasing: "Heads up — the deploy is paused" beats "I wanted to flag that the deployment has been temporarily suspended."
- "Hey", "FYI", "Heads up", "Quick one:" are valid openers when the source is announcing or flagging something.
- Keep technical precision intact. Slackifying ≠ dumbing down. Code, numbers, and names stay exactly as in the source.

### 5. Emoji policy

- Don't add emojis unless they obviously fit.
- The few that almost always work without feeling forced:
  - `:white_check_mark:` for completed/shipped
  - `:eyes:` for "look at this"
  - `:warning:` or `:rotating_light:` for outages/alerts
  - `:thread:` to point readers to a thread
- Match the source's energy. If the source has zero emojis, your output has at most one. If the source already uses emojis, mirror the density, don't increase it.

### 6. Mentions, channels, links

**Mention syntax** (use whichever the surface expects — when in doubt, plain `@username` is universally readable):

| What it references | API-grade syntax | UI-pasteable |
|---|---|---|
| User | `<@U012AB3CD>` (uses ID) | `@username` |
| Channel | `<#C123ABC456>` | `#channel-name` |
| User group | `<!subteam^GROUP_ID>` | `@group-name` |
| All active in channel | `<!here>` | `@here` |
| All in channel | `<!channel>` | `@channel` |
| Everyone in #general | `<!everyone>` | `@everyone` |

**Broadcast restraint:** if the source uses `@channel` / `@everyone` / `@here` casually ("Hey everyone!" greeting), strip the broadcast — it pings every member of the channel. Keep the broadcast only if the source clearly intends an actual all-hands ping (outage, deadline, vote).

**Links:** keep URLs intact. Markdown `[text](url)` → Slack-safe `<url|text>`. Raw URLs render as auto-links — leave them.

### 7. Single-message rule

Send one complete message, not "Hi" → "are you there?" → "I have a question." Multi-message fragmentation creates notification fatigue and is the most common Slack-newbie mistake. If the source you're rewriting is already split across multiple short blocks that should logically be one message, *combine* them.

### 8. Reactions instead of replies

For short acknowledgments (the source is essentially "ok," "got it," "thanks!", "sounds good"), the Slack-native move is an **emoji reaction on the previous message**, not a typed reply. If the rewrite would be a 1-2 word ack, return:

> `(consider reacting with 👍 / ✅ / 🙏 instead of typing a reply)`

The user can ignore the suggestion and post the text anyway, but flag it.

## What NOT to do

- **Don't add emojis the source didn't suggest.** Slack-flavor doesn't mean emoji-flavor.
- **Don't add "Hey team!" if the source had no greeting.** Maybe the user doesn't need one — channels show who you're posting to.
- **Don't fabricate details to make it punchier.** Same anti-fabrication rule as humanize-it: never invent specifics that weren't in the source.
- **Don't aggressively shorten if the source is already short.** A 2-sentence email becomes a 2-sentence Slack message, not a 1-word reply.
- **Don't translate technical content into "casual."** A status update can stay technical; it just shouldn't have email scaffolding around it.
- **Don't broadcast-ping casually.** Strip stray `@channel` / `@everyone` from greetings — they notify every member.
- **Don't insert generic placeholders.** `[Manager Name]`, `[insert deadline]`, `[your team]` — the user will add specifics. Leave the gap visible (`<your manager>`) only if the source explicitly needs one.

## Yellow flag — when not to slackify

Slack itself recommends restraint with formatting: save design effort for high-impact contexts (announcements, summaries, meeting notes, approval requests, status reports). If the source is already a 1-line casual ping ("can we move standup?"), don't add bold leads or emoji status indicators just because we *can*. Match the source's intent and weight. Over-formatting trivial messages is its own slop pattern.

## Output format

Return only the Slack-ready text. No preamble. No "Here's the Slackified version:" / "Let me know if you want it shorter." If the source was very long and you cut substantial detail, you can append a single line at the end like `(rest in thread)` — but only if that's actually useful.

If the user pastes multiple distinct messages, slackify each separately and return them with a blank line between.

## Quick before/after

**Before (email-style):**
> Hi team,
>
> I wanted to flag that the deployment to staging has been **temporarily paused** due to an unexpected issue with the database migration. Our team is currently investigating, and we will provide an update as soon as we have more information.
>
> Best regards,
> Alex

**After (Slack):**
> Heads up — staging deploy paused. Hit a snag in the DB migration; investigating now. I'll post an update here when we know more.
