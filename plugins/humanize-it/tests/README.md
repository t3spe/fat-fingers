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

## External corpora

For systematic fixture sampling beyond hand-picked examples, `download-corpora.sh` pulls three established AI-text datasets into a gitignored `corpora/` directory.

```bash
./download-corpora.sh           # download missing files (~1.3 GB total)
./download-corpora.sh --check   # report what's cached, no downloads
./download-corpora.sh --force   # re-download everything
```

| Corpus | Size | What it gives you |
|---|---|---|
| **HC3** (Hello-SimpleAI) | 141 MB | 24,322 *paired* human/ChatGPT answers across 5 domains (finance, medicine, open-QA, Reddit ELI5, Wikipedia). Best fit because each AI-side has a human reference. |
| **RAID test split** (liamdugan) | 1.2 GB | 8.6M LLM generations across 11 models, 11 genres, 4 decoding strategies, 12 adversarial attacks. Unlabeled (it's a leaderboard benchmark) — use the raw `generation` column for sampling. |
| **slop-forensics** lists | 32 KB | Empirical word/bigram/trigram lists derived from cross-model analysis. Use to audit/enrich the Tier 1/2/3 lists in SKILL.md. Note: list is biased toward creative writing — filter accordingly. |

The download script is idempotent: it skips files that already exist. Safe to re-run after blowing away `corpora/` — it'll rebuild from scratch.

### Sampling fixtures from corpora

Once `corpora/` is populated, `sample-corpora.py` draws random fixtures into `samples/` (also gitignored).

```bash
./sample-corpora.py                     # default: 2 HC3/domain (10 total) + 10 RAID, seed=42
./sample-corpora.py --hc3 5 --raid 30   # bigger sample
./sample-corpora.py --seed 123          # different draw
./sample-corpora.py --clean             # wipe samples/ before sampling
```

Output structure:

```
samples/
├── hc3/
│   ├── finance-01-<question-slug>.md           ← AI side (the slop)
│   ├── finance-01-<question-slug>.human.md     ← human reference
│   ├── medicine-01-<question-slug>.md
│   ├── medicine-01-<question-slug>.human.md
│   └── ...
└── raid/
    ├── raid-001.md
    ├── raid-002.md
    └── ...
```

HC3 samples ship with a `.human.md` sidecar — the same prompt's human-written answer. The runner skips `.human.md` files automatically and *also* scores them, surfacing a `human` column in the output for paired comparison. Useful interpretations:

- `human ≈ 0`, `after ≈ 0` — both rewrite and reference are clean. Skill matched human quality.
- `human ≈ 0`, `after >> 0` — skill produced something more AI-like than the human reference. Worth inspecting.
- `human >> 0`, `after ≈ 0` — skill produced something *cleaner than the human reference*. Often happens when the Reddit/forum human reference is itself stylistically slop-y. (Brandonwise scores text, not authorship.)
- `human` column shows `-` when no sidecar exists (e.g., curated fixtures and RAID).

### Running the runner against samples

`run.sh` reads `FIXTURES_DIR` from the environment, defaulting to `fixtures/`:

```bash
./run.sh                                 # curated regression (default)
FIXTURES_DIR=$PWD/samples/hc3 ./run.sh   # all HC3 samples
FIXTURES_DIR=$PWD/samples/raid ./run.sh  # all RAID samples
FIXTURES_DIR=$PWD/samples/hc3 ./run.sh 'finance-*.md'   # one domain
```

## Monotonicity checks (deterministic safety net)

Independent of brandonwise's score, the runner enforces five monotonicity rules. The rewrite must not contain *more* of any of these than the source did.

| Tell | Pattern | Why it leaks |
|---|---|---|
| **em dash** | `—` | LLM defaults to em dash for compound clauses even when source uses periods/commas. |
| **bold** | `**...**` | LLM converts inline-header colons (`Personal loan:`) into bold bullets, which is a different slop pattern. |
| **curly quote** | `" " ' '` | LLM defaults to typographic quotes; humans typing rarely reach for them. |
| **markdown list item** | lines starting with `- `, `* `, or `N. ` | LLM restructures unstructured prose into clean bulleted lists, introducing new structure that wasn't there. Frequent failure on recipes, ingredient lists, instructions. |
| **leak-phrase** | any phrase from `leak-patterns.txt` | LLM reaches for high-signal Tier 1 words/phrases (delve, leverage, "in terms of", "serves as", etc.) during rewriting that weren't in the source. |

A monotonicity violation always fails the test, regardless of the brandonwise score. The failure result names which check fired and the count delta, e.g. `mono: md-list 4→13`.

### Extending or tuning

- **Add a new pattern check:** add a `src_X` / `out_X` pair in `run.sh` using `count_pat` (regex) or `count_lists`-style helpers, then push onto `mono_violations`.
- **Edit the leak-phrase list:** `leak-patterns.txt` has one fixed-string pattern per line. Lines starting with `#` are comments. Re-run; no other changes needed.
- **Loosen the threshold:** if a rule produces too many false positives (e.g., normalizing inconsistent source formatting into consistent bullets), consider replacing the strict `>` comparison with a percentage threshold.

## Outputs

`outputs/*.out.md` holds the latest rewrite for each fixture. Gitignored — these are session artifacts. Useful for diffing across SKILL.md changes (`git stash` the change, run, save, unstash, run, diff outputs).

## Caveats

- **Brandonwise is one oracle, not ground truth.** A score of 0 doesn't mean the rewrite is perfect; it means the patterns brandonwise detects aren't there. Always eyeball the outputs.
- **The plugin is loaded from the local repo** via `--plugin-dir ..`, so the tests run against your working-tree SKILL.md, not the marketplace-installed version. Useful for iterating before you commit + push.
- **`claude -p` runs cost API quota.** 8 fixtures × 1 invocation each per run.
- **Rewrites are stochastic.** The same fixture can score 3/100 one run and 32/100 the next, depending on which Tier 1 word the model happens to reach for. If a fixture fails once, re-run before assuming a real regression. If it fails 3+ times in a row, the SKILL.md rule probably needs strengthening.

## Deterministic monotonicity check

The runner enforces one rule deterministically, regardless of what brandonwise scores: **em-dash monotonicity**. If the source has zero em dashes and the rewrite has any, the test fails with `mono: em-dash N→M`. This catches the most common rule-leak — em dashes are the punctuation tell the LLM most often introduces during rewriting, even with the SKILL.md hard rule against it. The runner-level check makes the regression visible and unambiguous.

To extend monotonicity to other tells (Tier 1 words, "not just X but Y" constructions, curly quotes), add similar grep-based checks in `run.sh`.
