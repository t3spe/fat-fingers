---
name: slackify
description: Rewrite text into a Slack-appropriate message. Use when the user asks to "slackify," "slackify it," "make it Slack-appropriate," "format for Slack," "post this to Slack," "send this in Slack," "convert to Slack message," or pastes content (an email, a writeup, an AI response, a long-form note) and asks to make it suitable for posting in a Slack channel or DM. Handles markdown-flavor conversion (`**bold**` → `*bold*`, etc.), strips email scaffolding (greetings, sign-offs), trims length for chat context, and adjusts tone toward casual-professional.
---

Rewrite the input as a Slack message. Return only the rewritten text — no preamble, no "Here's your Slack version," no meta-commentary.

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
| `[text](url)` | `<url|text>` (Slack URL format) |
| `` `code` `` | `` `code` `` (same — backticks) |
| ```` ```block``` ```` | ```` ```block``` ```` (same — triple backticks) |
| `- bullet` or `* bullet` | `• bullet` (or `- bullet`; both render) |
| `1. item` | `1. item` (same) |
| `> quote` | `> quote` (same) |

Strip headers entirely (no `#`, `##`, etc.). If the original used a header to introduce a section, replace with a `*bold first phrase*:` lead or just inline it.

### 3. Trim for chat context

- Cut anything that wouldn't survive a glance on a phone screen.
- One idea per paragraph. Use line breaks generously — Slack rewards visual scanning.
- For longer source material, lead with the conclusion (TL;DR style) and let detail follow.
- If the source is over ~6 short paragraphs, suggest threading: prepend `*TL;DR:* <one-line summary>` then put the rest below or note that the rest belongs in a thread reply.

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

- Preserve `@username` references as `<@username>` if Slack-formatted, or keep plain `@username` if not (the original surface will resolve them).
- Preserve `#channel-name` references the same way.
- Keep URLs intact. If the original had a markdown link `[text](url)`, convert to Slack format `<url|text>`. If raw URL, leave it.

## What NOT to do

- **Don't add emojis the source didn't suggest.** Slack-flavor doesn't mean emoji-flavor.
- **Don't add "Hey team!" if the source had no greeting.** Maybe the user doesn't need one — channels show who you're posting to.
- **Don't fabricate details to make it punchier.** Same anti-fabrication rule as humanize-it: never invent specifics that weren't in the source.
- **Don't aggressively shorten if the source is already short.** A 2-sentence email becomes a 2-sentence Slack message, not a 1-word reply.
- **Don't translate technical content into "casual."** A status update can stay technical; it just shouldn't have email scaffolding around it.

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
