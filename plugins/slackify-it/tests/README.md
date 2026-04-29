# slackify-it tests

Property-check regression suite. No external oracle needed — slackify rules are deterministic enough that grep-style assertions catch real issues.

## Setup

Just need the `claude` CLI (which you already have if you're using the plugin). No npm/pip dependencies.

## Run

```bash
./run.py                       # all fixtures
./run.py 'email-*.md'          # glob filter
./run.py --verbose             # show full rewrite for each fixture
```

The runner:
1. For each fixture, invokes the local plugin via `claude --plugin-dir .. -p "/slackify-it:slackify <text>"`.
2. Saves the rewrite to `outputs/`.
3. Applies universal property checks + class-specific checks based on filename prefix.
4. Reports a one-line pass/fail per fixture.

Exits non-zero if any fixture fails.

## Fixture classes (filename prefix → checks dispatched)

| Prefix | Tests | Checks beyond universal |
|---|---|---|
| `email-*` | Strips email scaffolding | no greeting ("Hi team" / "Dear all" / etc.), no sign-off ("Best regards" / "Cheers,") |
| `markdown-*` | Converts AI markdown to mrkdwn | universal only (no `**bold**`, no `## headers`, no `[text](url)`) |
| `short-*` | Yellow-flag respect | output length ≤ 150 chars |
| `ack-*` | Suggests reaction | output contains "consider reacting" or similar |
| `long-*` | TL;DR + thread suggestion | output contains "TL;DR" or "thread" |
| `broadcast-*` | Strips casual broadcasts | no `@channel` / `@everyone` / `@here` (without `<!` prefix) |
| `table-*` | Converts tables | universal `no markdown table` check fires |
| `headers-*` | Replaces `#`/`##` with `*bold lead:*` | universal `no markdown header` check fires |

## Universal checks (apply to every fixture)

| Check | Why |
|---|---|
| no `**` | Slack uses single asterisks for bold; double-asterisk is invalid |
| no `# / ## / ### ` lines | Slack only renders headers in markup mode |
| no `[text](url)` | Slack hyperlinks are `<url\|text>` |
| under 4000 chars | Slack hard recommended max |
| no markdown tables (`\|...\|`) | Slack doesn't render tables |

## Adding a fixture

1. Drop a slop sample in `fixtures/<class>-<NN>-<slug>.md` where `<class>` matches one of the classes above.
2. Re-run. The runner dispatches the right checks based on prefix.

To add a new class, edit `run.py`: define a new check function and add it to `CLASS_CHECKS`.

## Outputs

`outputs/*.out.md` holds the latest rewrite for each fixture. Gitignored. Useful for diffing across SKILL.md changes (`git stash`, run, save, unstash, run, diff).

## Caveats

- **Property checks are necessary but not sufficient.** Output that passes all checks could still be a bad rewrite (e.g., wrong tone, lost meaning). Always eyeball outputs after major SKILL.md changes.
- **Plugin is loaded from local repo** via `--plugin-dir ..`, so tests run against your working-tree SKILL.md, not the marketplace-installed version.
- **`claude -p` runs cost API quota.** ~10 seconds per fixture × 9 fixtures ≈ 90 seconds + cost.
- **No stochastic-leak protection.** Unlike humanize-it, slackify rules are mechanical enough that re-runs should be consistent. If you see flaky failures, that's a real signal worth investigating.
