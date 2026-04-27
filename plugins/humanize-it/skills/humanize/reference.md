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

**Bifurcated adaptation (Human-LLM Coevolution, arXiv 2025).** The arms race is asymmetric. Words that *dropped* after public exposure: "intricate," "realm," "pivotal," "showcasing" (all began declining March-April 2024 once researchers flagged them). Words that *kept rising* despite exposure: "significant," "additionally" — common enough that their presence alone doesn't trigger suspicion. Practical implication: Tier 1 lists are not stable across years; the skill should periodically retire dated tells and add emerging ones.

**Multi-marker clustering is the strongest signal (Kobak deep read).** Phrases like *"meticulously delving into the intricate web"* combine three Tier 1/2 markers in five words. Clustering is an order of magnitude stronger as a tell than three isolated occurrences across a long document. The skill should weight cluster-density above raw count — three Tier 1 words in one clause is almost dispositive; three Tier 1 words across 1000 words might be coincidence.

**Positional context matters (Juzek & Ward 2024).** Experimental finding: "delve" *at sentence-start* triggered measurably more user wariness than mid-sentence "delve." Position is itself a feature. Sentence-initial Tier 1 words deserve more aggressive treatment than mid-clause ones.

**POS distribution shift (Kobak 2024).** 2024 excess vocabulary is **66% verbs and 18% adjectives** — a sharp departure from historical noun-heavy excess vocabulary. When scanning text, verb-heavy slop is now the dominant pattern. If a paragraph's verbs cluster among "delve, leverage, navigate, harness, foster, unleash, elevate," that's stronger evidence than the same number of slop nouns.

**Genre-specific calibration (Kobak 2024).** LLM-text rates vary wildly by venue:
- Nature / Science / Cell papers: 6–7%
- MDPI / Frontiers journals: 17%
- Computational fields: 20%+
- Sensors (South Korea): 31%
- Computation papers (China): 35%
"Easily-detectable LLM usage was negatively correlated with perceived prestige." The skill's strictness should arguably calibrate to context: text claiming to be from a high-prestige venue should be held to a stricter standard than computational-track conference papers.

---

## Phrase-frequency multipliers (ai-text-humanizer.com)

Multi-word phrases are stronger tells than single words because the combinatorial frequency is more anomalous. Above-baseline multipliers from corpus comparisons:

| Phrase | Frequency multiple |
|---|---|
| "Notable works include / Notable figures" | ~120× |
| "In today's fast-paced world" | ~107× |
| "Aims to explore" | ~50× |
| "Aligns" (as verb) | ~16× |
| "Surpassing" | ~12× |
| "Tragically" (out of crisis context) | ~11× |
| "Impacting / Making an impact" | ~11× |

Treat these phrases as Tier 1 equivalents — one occurrence is dispositive.

---

## Statistical metric ranges (brandonwise/humanizer)

Concrete targets that distinguish human and AI text. The skill can't compute these mid-rewrite, but they're useful as Pass 2 sanity checks ("does this *feel* in the human range?").

| Metric | Human | AI |
|---|---|---|
| Burstiness (sentence-length variation) | 0.5–1.0 | 0.1–0.3 |
| Type-token ratio (vocabulary diversity) | 0.5–0.7 | 0.3–0.5 |
| Sentence-length CoV | 0.4–0.8 | 0.15–0.35 |
| Trigram repetition | < 0.05 | > 0.10 |
| Flesch-Kincaid grade level | varies widely | consistently 8–12 |

If a rewrite ends up with all sentences in a tight band, the skill should deliberately break the uniformity even if no individual sentence triggers another rule.

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

## Structural patterns: supplementary catalog

SKILL.md covers the ten primary structural patterns (em dashes, negative parallelisms, rule of three, false agency, copula inflation, significance inflation, rigid scaffolding, random bolding, Unicode formatting, generic metaphors). The literature identifies a few more diagnostic patterns worth knowing about — they're less common than the SKILL.md ten but show up in long-form text:

- **The "elegant variation" tic.** Substituting synonyms purely to avoid repetition ("the company... the firm... the organization... the entity"). Real writers repeat the right word when it's the right word.
- **Symmetric paragraph length.** All paragraphs roughly the same size. Real writers have one-line paragraphs and twelve-line paragraphs in the same piece.
- **Gratuitous parallel structure.** "We build, we ship, we iterate." LLMs reach for parallelism even when the underlying ideas aren't parallel. Different from rule-of-three triplets — this is about syntactic mirroring across consecutive sentences.

---

## Yellow flags: what *not* to flag

Some patterns commonly cited as AI tells aren't reliable on their own. Flagging them mechanically produces false positives and over-corrects human writing.

- **Sophisticated vocabulary alone.** "Delve," "ascertain," "multifaceted" — these are common in professional writing (consulting, academic, legal). One occurrence in a work email is not a tell. A *cluster* with structural patterns is.
- **Perfect grammar / no typos.** Grammarly is universal in professional contexts. Spell-checked output ≠ AI output.
- **No contractions.** Could be ESL, formal register, stylistic preference, or institutional voice. Don't expand contractions just to humanize, and don't flag their absence.
- **A single Tier 1 word in otherwise idiosyncratic prose.** If the writing has voice, opinion, specific anecdotes, or unusual rhythm, leave the word alone. The Tier system is calibrated for *slop*, where the prestige word is one of many tells. In isolation, it's just vocabulary.

The skill's job is to remove the convergence of slop signals. It's not to flatten every piece of writing into the same minimalist register. Professional, formal, or technical writing should stay professional, formal, or technical — just without the AI fingerprints.

---

## Positive prescription: voice and specificity

Charlie Guo's "Field Guide to AI Slop" (Oct 2025) makes the most useful positive observation in the literature: *the best defense against AI slop isn't to police style, it's to cultivate specificity*.

> "My own defense against AI slop isn't to worry too much about style and structure. It's to cultivate specificity: to write things rooted in particular knowledge and tangible experience. To develop a voice and a point of view, and stay as true to them as I can. These are things that AI still struggles to replicate convincingly."

Two implications for the humanize skill:

1. **Specificity > style policing.** A rewrite that adds one concrete number, name, or anecdote does more for human-ness than removing five Tier 1 words. The Step 6 specificity-injection rule in SKILL.md exists for this reason — but it's also a reminder that the skill should *prefer* opportunities to anchor in fact over opportunities to swap synonyms.
2. **Voice is invariant.** If the source has a strong voice (sarcasm, opinion, specific perspective), preserve it. Don't sand it down toward neutral "human-sounding" prose. Voice is harder to fake than vocabulary.

---

## Sycophancy: data, causality, variants

**Prevalence (SycEval 2025).**
- 58% of LLM responses across tested models contain sycophantic content.
- 78.5% persistence rate — once a model starts being sycophantic, it stays sycophantic across the conversation.

**Causality (Sean Goedecke, 2024).** Two underdiscussed drivers:
- *Memory-driven sycophancy.* Once ChatGPT gained memory features, surfacing critical assessments of users' personalities triggered defensiveness ("Has narcissistic tendencies" → "No I don't!"). Engineers responded with extreme sycophancy RLHF to hide critical reads. So sycophancy isn't just thumbs-up gaming — it's also damage control.
- *Arena benchmark gaming.* Models are deliberately tuned to win anonymous comparison contests, which reward user-pleasing language. The optimization target itself selects for sycophancy.

**Variants beyond opening flattery:**
- *Closing teasers* — ending responses with manipulative engagement-bait suffixes: "I could go deeper if you want," "Let me know if you'd like more on X." Distinct from inspirational closers; this is a chat-trained tic. Cut.
- *Vicious cycle* — once a user is validated by an inflated self-assessment, real-world friction feels worse, pushing them back to the model. The skill can't fix this dynamic, but rewrites should avoid generating new sycophantic reassurance.

**Operational rules already in SKILL.md:**
- Forbidden first words ("Great," "Certainly," "Okay," "Sure," "Absolutely," "Of course") — catches the most common openers.
- Anti-sycophancy framing trick (in plugin README): present the work as someone else's, or use a question rather than a statement.

**Citation-based exploitation (UNU 2025).** Domain-specific finding: citation-based rebuttals trigger the *highest* rate of regressive sycophancy. Pre-emptive contradictions (claims made *before* model response) trigger 61.75% sycophancy versus 56.52% for post-response rebuttals. Practical implication: when humanizing text that *contains* counter-claims-with-citations, be especially careful — the model is most likely to have caved to the citation rather than to the truth at that exact moment.

**Expanded mitigation menu (WhyTryAI, Stephen Mwangi).** Beyond the standard tricks, these techniques work in real practice:
- *Request criticism directly:* "What are the biggest risks and reasons this might fail?"
- *Multiple-option comparison:* present 2+ alternatives so the model evaluates pros/cons instead of validating a single one.
- *Forced specificity:* "Rate it out of 10 and walk me through your reasoning" prevents vague praise.
- *Critical persona adoption:* "You're Gordon Ramsay" naturally authorizes blunt feedback.
- *Explicit permission to disagree:* "challenge weak reasoning directly," "think independently rather than just being agreeable."
- *Fresh chat strategy:* start a new conversation for critical feedback; memory features encode past validation patterns.

These are upstream prompt techniques (relevant to plugin README usage tips), not rewrite-pass rules — but they explain why the "frame as someone else's work" trick works.

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
- **Charlie Guo, "The Field Guide to AI Slop"** (*Artificial Ignorance*, Oct 2025) — sources the unearned-profundity, generic-metaphor, and Unicode-formatting rules in SKILL.md; also the "cultivate specificity" positive prescription.
- **conorbronsdon/avoid-ai-writing v3.3.1** — sources novelty inflation, emotional flatline, false ranges, false concession, parenthetical hedging, inline-header lists, title-case headings, "worth [verb]ing," promotional language, acknowledgment loops, reasoning chain artifacts, numbered list inflation, and the patch-vs-rewrite threshold.
- **stephenturner/skill-deslop** — sources magic adverbs ("quietly"), invented concept labels, and the read-aloud test framing.
- **NousResearch/autonovel ANTI-SLOP.md** — sources the "false-depth pattern" (restate problem in fancier words → list obvious considerations → vague call to action) and structural symmetry observations.
- **brandonwise/humanizer** — sources the statistical metric ranges (burstiness, TTR, sentence CoV) and the composite scoring approach.
- **Sean Goedecke, "Sycophancy is the first LLM dark pattern"** — sources memory-driven sycophancy, arena gaming, and closing-teaser variant.
- **Human-LLM Coevolution** (arXiv 2502.09606) — sources the bifurcated-adaptation finding (intricate/realm/pivotal dropped; significant/additionally rose).
- **ai-text-humanizer.com phrase catalog** — sources the phrase-frequency multipliers table.
