# slackify-it

Rewrite text into a Slack-appropriate message. Strips email scaffolding (greetings, sign-offs), converts standard markdown to Slack's flavor (`**bold**` → `*bold*`, etc.), trims for chat context, and matches casual-professional tone.

## Install

```bash
/plugin marketplace add t3spe/fat-fingers
/plugin install slackify-it@fat-fingers
/reload-plugins
```

## Use it

Direct invocation:

```
/slackify-it:slackify <text to convert>
```

Or paste any email / writeup / AI response into a normal message and ask "slackify this" / "make this slack-appropriate" / "format for slack."

## What it does

- Strips email scaffolding ("Hi team," "Best regards," signatures, "Per my last message").
- Converts markdown to Slack's flavor: `**bold**` → `*bold*`, `## headers` → no headers, `[text](url)` → `<url|text>`, etc.
- Trims for chat: lead with the conclusion, use line breaks, suggest threading for long material.
- Adjusts tone: contractions, direct phrasing, Slack-appropriate openers ("Heads up", "FYI") — but only when they fit the content.

## What it won't do

- Add emojis the source didn't suggest.
- Fabricate details to make it punchier.
- Translate technical content into casual; precision stays.
- Aggressively shorten content that's already short.

## Plays well with

- **`humanize-it`** (sibling plugin in this marketplace) — if your source is AI-sounding *and* needs to go in Slack, run humanize-it first to strip the slop, then slackify-it to format for chat.

## Version

`0.1.0` — see [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json).
