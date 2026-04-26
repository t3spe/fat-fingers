# Humanize: research grounding and extended inventory

Background material for the humanize skill. SKILL.md contains the operational rules; this file explains *why* those rules exist and provides expanded word inventories for edge cases.

---

## The convergence model: what actually identifies AI text

Academic research (Kobak et al., *Science Advances* 2025; Juzek & Ward 2024; Taylor & Francis 2025) converges on four measurable dimensions that together identify LLM-generated text. No single one is dispositive — the *convergence* is the tell.

1. **Low lexical diversity.** AI text has lower type-token ratios and fewer hapax legomena (words appearing only once). It occupies a more constrained linguistic space — intrinsic dimensionality ~8 vs. ~9–10 for human text.
2. **Uniform sentence rhythm.** Less variation in sentence length and structure. Human text is "bursty" — clusters of repetition followed by lulls. AI distributes patterns evenly.
3. **Overuse of prestige vocabulary.** Words RLHF annotators reward as "fluent" and "professional" — delve, leverage, robust, comprehensive — appear at multiples of human baseline.
4. **Absence of personal idiosyncrasy.** No tics, no opinions, no specific anecdotes, no register modulation. The voice is a flat average.

A complete humanization addresses all four. Removing prestige vocabulary alone leaves the structural fingerprints intact.

---

## Empirical word frequency baselines (Kobak et al. 2025)

15 million PubMed abstracts, 2010–2024. Frequencies are 2024 / pre-2022 baseline.

| Word | Frequency multiple |
|------|-------------------|
| delve | 25.2× |
| showcasing | 9.2× |
| underscores | 9.1× |
| pivotal | ~6× |
| comprehensive | ~5× |
| intricate | ~5× |
| navigate (metaphorical) | ~4× |
| leverage | ~4× |
| realm | ~4× |

By 2024, ~13.5% of biomedical abstracts (≈200,000 papers) showed signs of LLM processing. A Scopus follow-up: 46.4% of all historical uses of "delve" concentrated in 2023–2024 alone.

**Caveat (Juzek & Ward 2024):** most overused LLM words were already increasing in human writing before ChatGPT. LLMs accelerate existing trends rather than inventing them. Once "delve" was publicly outed as an AI marker, frequency dropped — but other markers (e.g., "significant") kept rising. Treat the lists as living, not fixed.

---

## Extended word inventory by category

The Tier 1/2/3 lists in SKILL.md are the operational cut. Below is a fuller categorical inventory, useful when scanning unfamiliar text.

### Verbs (LLM-overused)
delve, leverage, utilize, harness, streamline, underscore, foster, facilitate, navigate, unlock, unleash, empower, elevate, amplify, catalyze, illuminate, resonate, spearhead, supercharge, bolster, embark, pioneer.

### Adjectives (prestige inflation)
pivotal, robust, seamless, cutting-edge, groundbreaking, multifaceted, holistic, comprehensive, transformative, unprecedented, nuanced, meticulous, intricate, paramount, invaluable, ever-evolving, bespoke, myriad, unparalleled, unwavering, profound.

### Nouns (vague abstractions)
landscape, tapestry, realm, synergy, testament, paradigm, beacon, cornerstone, interplay, plethora, nexus, kaleidoscope, treasure trove, milestone, journey, gateway, linchpin, hallmark, embodiment.

### Transitions (overused to the point of being tells)
furthermore, moreover, notably, importantly, additionally, ultimately, consequently, nevertheless, accordingly, thus, hence.

### Hedge stack components (combine into "may potentially," "could possibly")
may, can, might, could, possibly, potentially, perhaps, arguably, generally, typically, often, sometimes, usually.

### Filler intensifiers (delete)
very, really, truly, literally, actually, just, quite, rather, simply, essentially, basically, fundamentally, certainly, absolutely, indeed.

---

## Structural patterns: full catalog

Beyond the seven structural rules in SKILL.md, the literature identifies several more diagnostic patterns:

- **Excessive bullet points.** Bullets for things that are prose. Three-word bullets that should be one sentence.
- **Rigid intro-body-conclusion scaffolding** for short pieces. A 200-word answer doesn't need a thesis paragraph and a summary.
- **Meta-commentary about the text itself.** "In this article, we will explore...", "As we'll see...", "In summary..."
- **Uniformly formal register.** No modulation between casual and formal even when context warrants it. Humans shift; AI averages.
- **The "elegant variation" tic.** Substituting synonyms purely to avoid repetition ("the company... the firm... the organization... the entity"). Real writers repeat the right word.
- **Symmetric paragraph length.** All paragraphs roughly the same size. Real writers have one-line paragraphs and twelve-line paragraphs in the same piece.
- **Gratuitous parallel structure.** "We build, we ship, we iterate." LLMs reach for parallelism even when the underlying ideas don't parallel.

---

## Sycophancy data (SycEval 2025)

- 58% of LLM responses across tested models contain sycophantic content.
- 78.5% persistence rate — once a model starts being sycophantic, it stays sycophantic across the conversation.
- The forbidden-first-word list in SKILL.md ("Great," "Certainly," "Okay," "Sure," "Absolutely," "Of course") catches the most common openers.
- Anti-sycophancy framing trick: present the work as someone else's, or use a question rather than a statement. Removes the model's urge to please.

---

## Why the two-pass approach works

Single-pass instructions ("write tersely, no slop") consistently fail because the model's default sampling distribution still favors slop tokens. The two-pass structure (rewrite, then audit) works because:

1. Pass 1 produces a candidate that's closer to slop than the model thinks.
2. Pass 2 forces an *adversarial* read — "what would make this obviously AI-generated?" — which surfaces patterns the generative pass smoothed over.
3. The audit checklist gives concrete things to look for, so the second pass isn't vague.

The most effective open-source skill (blader/humanizer) uses this exact pattern. So does this skill.

---

## Related tools and references

For practitioners who want to go deeper:

- **tropes.fyi** — interactive catalog of 32 documented AI writing tropes with a paste-in checker.
- **Wikipedia: "Signs of AI writing"** — community-maintained reference, evidence-based, tracked by LLM era.
- **slop-forensics** (sam-paech) — empirical per-model word/bigram/trigram frequency datasets.
- **antislop-sampler** (sam-paech) — inference-time prevention; backtracks when slop tokens form.
- **Kobak et al. 2025** — peer-reviewed PubMed frequency baselines.
- **Juzek & Ward 2024** — "Why Does ChatGPT 'Delve' So Much?" on pre-existing trends.
- **HxHippy/DeSlop** — open-source Chrome extension, 600+ patterns, runs locally.
