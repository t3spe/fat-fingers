# humanize-it

Rewrite AI-sounding text so it reads like a human wrote it. Targets em-dashes, LinkedIn cadence, hedging, sycophancy, bullet-point bloat, and the rest of the LLM-isms. Two-pass process (rewrite + self-audit) with research-backed word tiers and structural pattern detection.

## Install

```bash
/plugin marketplace add t3spe/fat-fingers
/plugin install humanize-it@fat-fingers
/reload-plugins
```

## Use it

Direct invocation:

```
/humanize-it:humanize <text to rewrite>
```

Or paste AI-sounding text into a normal message and ask Claude to humanize it — the skill auto-fires on phrases like "humanize this," "de-AI this," "strip the fluff," "make it sound human," "condense."

## Usage tips

**Frame the source as someone else's work.** When you ask Claude to humanize text *you* wrote (or that "we" wrote), the model softens its critique to be polite — it leaves more slop in. Phrasing like *"my colleague drafted this; rewrite it to sound human"* removes the sycophancy reflex and consistently produces tighter rewrites. (Backed by SycEval 2025: anti-sycophancy framing reduces hedge artifacts.)

**Run on chunks, not whole documents.** The skill's 40–60% length target works best on paragraph-to-page-sized inputs. For long docs, paste sections one at a time — you'll catch slop the holistic pass smooths over.

**Re-run the audit on borderline output.** If the first rewrite still feels slightly LLM, ask the skill to run Pass 2 only: *"audit this against the humanize self-audit checklist."* It'll catch what survived.

## What's inside

- [`skills/humanize/SKILL.md`](./skills/humanize/SKILL.md) — operational rules (5 rewrite steps + 12-item self-audit)
- [`skills/humanize/examples.md`](./skills/humanize/examples.md) — 4 worked before/after pairs
- [`skills/humanize/reference.md`](./skills/humanize/reference.md) — research grounding (Kobak 2025, the convergence model, extended word inventory)

## Version

`0.2.0` — see [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json).
