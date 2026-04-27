# humanize-it tests

Empirical regression suite. Scores rewrites of slop fixtures against [brandonwise/humanizer](https://github.com/brandonwise/humanizer) (independent open-source AI-text scorer) as the oracle.

## Setup

One-time deps:

```bash
# 1. brandonwise/humanizer (the scoring oracle)
git clone https://github.com/brandonwise/humanizer /tmp/humanizer
cd /tmp/humanizer && npm install -g .

# 2. Confirm
humanizer --help
```

The runner also needs the `claude` CLI (Claude Code), which you already have if you're using the plugin.

## Run

From this directory:

```bash
./run.sh                       # all fixtures
./run.sh '02-*.md'             # one fixture (or glob)
THRESHOLD=15 ./run.sh          # stricter pass bar (default <25)
```

The runner:
1. For each fixture, scores the original via `humanizer score` (0–100; lower = more human).
2. Invokes the locally-installed plugin via `claude --plugin-dir .. -p "/humanize-it:humanize <text>"`.
3. Saves rewrites to `outputs/`.
4. Scores the rewrite. **Pass** if score `< $THRESHOLD` OR if the rewrite is a substance-check void flag.

Exits non-zero if any fixture fails.

## Fixtures

Each fixture targets a different rule cluster. Tag-style coverage:

| # | File | Targets |
|---|---|---|
| 01 | `marketing-slop.md` | Tier 1+2 pile-up; substance-check void path |
| 02 | `linkedin-thought-leader.md` | Emoji bullets, "I'm thrilled," numbered list inflation, inspirational closer, hashtags |
| 03 | `tech-blog-bloat.md` | Em dashes, "in today's…", negative parallelism, "let's dive in," persuasive authority tropes |
| 04 | `academic-abstract.md` | The Kobak-style prestige pile-up ("delving into the intricate interplay…") |
| 05 | `corporate-update.md` | Title case headings, inline-header lists ("**Performance:** Performance…"), numbered list inflation, "the future remains bright" |
| 06 | `yellow-flag-human.md` | Real engineering Slack message with one Tier 1 word — should be **left mostly alone** |
| 07 | `content-free-void.md` | Pure abstraction; should return void flag |
| 08 | `tier3-density.md` | Six transition-words in six sentences; tests Tier 3 density rule |

## What the scores mean

[brandonwise's scoring](https://github.com/brandonwise/humanizer#how-scoring-works) blends 70% pattern detection and 30% statistical uniformity (burstiness, type-token ratio, trigram repetition). Bands:

| Score | Band |
|---|---|
| 0–25 | mostly human |
| 26–50 | lightly AI-touched |
| 51–75 | moderately AI-influenced |
| 76–100 | heavily AI-generated |

Default pass bar is `<25`. The yellow-flag fixture (06) deliberately starts low (~2) and should stay low — that fixture catches over-correction regressions.

## Adding a fixture

1. Drop a slop sample as `tests/fixtures/NN-name.md`.
2. Re-run. The score before/after will tell you if the skill handles it.
3. If it doesn't, you've found a gap — patch SKILL.md, re-run.

Real-world sample sources: LinkedIn posts, B2B SaaS About pages, Medium tags like #productivity, ChatGPT shared conversations, AI-published Substacks.

## Outputs

`outputs/*.out.md` holds the latest rewrite for each fixture. Gitignored — these are session artifacts. Useful for diffing across SKILL.md changes (`git stash` the change, run, save, unstash, run, diff outputs).

## Caveats

- **Brandonwise is one oracle, not ground truth.** A score of 0 doesn't mean the rewrite is perfect; it means the patterns brandonwise detects aren't there. Always eyeball the outputs.
- **The plugin is loaded from the local repo** via `--plugin-dir ..`, so the tests run against your working-tree SKILL.md, not the marketplace-installed version. Useful for iterating before you commit + push.
- **`claude -p` runs cost API quota.** 8 fixtures × 1 invocation each per run.
