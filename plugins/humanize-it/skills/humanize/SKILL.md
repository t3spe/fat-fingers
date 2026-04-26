---
name: humanize
description: Transform LLM-generated text into condensed, human-like, terse prose. Use when the user asks to "humanize," "de-AI," "make it sound human," "rewrite tersely," "condense," "strip the fluff," "make it punchy," "remove LLM voice," or any variation of converting verbose/robotic AI output into tight natural writing. Also trigger when the user pastes a block of text and asks to shorten, tighten, or fix the tone to sound less like a chatbot. Works on emails, docs, READMEs, blog posts, social posts, technical writing, reports.
---

Transform verbose LLM-generated text into condensed, natural, human-written prose. Two-pass process: rewrite, then self-audit.

For worked before/after examples, see `examples.md`. For the research grounding (Kobak/Juzek findings, expanded word inventory, the convergence model), see `reference.md`.

**Why all these rules together?** AI text is identified by *convergence*, not any single tell: low lexical diversity + uniform sentence rhythm + overuse of prestige vocabulary + absence of personal idiosyncrasy. A perfect rewrite addresses all four. Removing slop is necessary but not sufficient — you also need to inject specificity (concrete numbers, names, claims) where the original was vague.

---

## Pass 1: Rewrite

### Step 1: Cut the filler

Most LLM text is 40-60% filler by volume. Delete before you rephrase.

**Substance check first.** Before rewriting, ask: does this text make any falsifiable claim? Specific numbers, names, dates, behaviors, mechanisms, comparisons? If after stripping filler there's nothing concrete left — just abstractions about "empowering," "elevating," "transforming," "unlocking value" — don't dress up emptiness in fewer words. Return:

> `(no substantive content: <one-line description of what the source was, e.g. "marketing copy with no concrete claims">)`

The user can override with "rewrite anyway" if they need polished slop for some reason. Default is to call out the void.

**Filler phrases — delete on sight:**
- "It's worth noting that...", "It's important to understand that...", "It should be noted that..."
- "As previously mentioned...", "As noted above...", "As discussed earlier..."
- "At the end of the day...", "When it comes to...", "In terms of...", "The fact that..."
- "In order to..." → "To..."
- "I think it's fair to say..." → just say it

**Hedge stacking — collapse to one claim or delete:**
- "may potentially" → "may" or just state it
- "could possibly" → "could" or just state it
- "it is generally considered" → state the thing
- "tends to typically" → pick one

**Intensifiers and filler adverbs — delete:**
- Certainly, Absolutely, Indeed, Essentially, Basically, Fundamentally
- Very, really, truly, literally, actually, just, quite, rather, simply
- Importantly, Significantly, Notably, Interestingly, Remarkably

**Sycophantic openers — delete entirely:**
- "Great question!", "That's a really interesting point", "Absolutely! Let me..."
- Any compliment about the reader's question or thinking
- "I'd be happy to help with that!"
- **Forbidden first words:** Great, Certainly, Okay, Sure, Absolutely, Of course. Never start a response with these. (SycEval 2025: 58% of LLM responses contain sycophancy with 78.5% persistence once triggered.)

**Meta-commentary — delete:**
- "Let me break this down:", "Here's what you need to know:"
- "In this section, we'll explore...", "Let's take a closer look at..."
- "There are several key factors to consider: First... Second... Third..."
- Don't announce what you're about to say. Just say it.

### Step 2: Kill the LLM vocabulary

Three tiers — a flat ban list creates false positives.

**Tier 1: Always flag and replace.** These words appear at 5–25× above human baseline frequency in LLM output (Kobak et al., *Science Advances*, 2025). One occurrence is a tell.

| Kill | Replace with |
|------|-------------|
| delve | (delete, or: examine, look at, dig into) |
| leverage | use |
| utilize | use |
| facilitate | help, enable, let |
| comprehensive | (delete, or be specific about scope) |
| robust | (delete, or name the specific quality: fast, reliable, tested) |
| streamline | simplify, speed up |
| holistic | (delete) |
| synergy | (delete) |
| multifaceted | (delete) |
| showcasing | showing |
| underscores | shows, highlights |
| tapestry | (delete — unless literally about fabric) |
| realm | area, field, domain |
| beacon | (delete) |
| cornerstone | (delete, or: foundation, basis) |
| nexus | (delete) |
| interplay | interaction, relationship |
| paradigm | model, approach |
| testament | proof, evidence |
| pivotal | key, critical, important |
| transformative | (delete, or prove the transformation) |
| unprecedented | (delete, or prove it's actually unprecedented) |
| bespoke | custom |
| myriad | many |

**Tier 2: Flag when they cluster.** One use might be fine. Two in a paragraph is a pattern. Three is slop.

landscape, ecosystem, innovative, seamless, cutting-edge, groundbreaking, game-changer, empower, harness, unleash, supercharge, foster, navigate, unlock, elevate, amplify, spearhead, catalyze, nuanced, paramount, invaluable, meticulous, intricate, ever-evolving, plethora, treasure trove, kaleidoscope.

**Tier 3: Flag only at high density.** Common words that are individually fine but become tells when they pile up.

furthermore, moreover, notably, additionally, consequently, accordingly, nevertheless, ultimately, journey (metaphorical), gateway, milestone, linchpin, straightforward, genuinely, honestly, resonate, illuminate.

### Step 3: Fix structural patterns

Equally diagnostic as word choice. AI text has structural fingerprints.

- **Em dashes — limit to one per 500 words max.** Strongest punctuation-level AI tell. Replace with periods, commas, colons, or parentheses.
- **Negative parallelisms — rewrite or delete.** "It's not just X — it's Y" or "Not merely X, but Y" appears in nearly every LLM's default output. Just say Y.
- **Break the rule of three.** LLMs default to triplets ("innovation, inspiration, and insights"). Use two items or four. Or pick the one that matters.
- **False agency — remove.** Don't give inanimate things human verbs. "This framework enables teams to..." → "Teams can use this framework to..." or just "Teams can...". Objects don't enable, empower, unlock, or drive. People do things.
- **Copula inflation — use "is".** "Serves as", "acts as", "functions as", "operates as" → "is". If something is a thing, say it is that thing.
- **Significance inflation — deflate.** "Marking a pivotal moment in the evolution of..." → state the fact. "Representing a watershed shift in..." → say what happened.
- **Rigid scaffolding — remove.** Don't reproduce intro-body-conclusion for anything under 1000 words. Start with the most important point. End when you're done.

### Step 4: Fix the rhythm

AI text has measurably uniform sentence length. Human text is bursty — short punches mixed with longer constructions.

- Vary sentence length deliberately. After two medium sentences, use a short one. Then maybe a longer one.
- Rough mix: 20% short (under 8 words), 50% medium (8–20 words), 30% long (20+ words). Don't measure — feel for monotony and break it.
- If every sentence in a paragraph is 15–20 words, something is wrong.
- One- or two-word sentences are fine occasionally. They punch.
- Don't start three consecutive sentences with the same word or structure.

### Step 5: Apply the rewrite principles

1. **Active voice.** Subject-verb-object. Name the actor. "The decision was made to..." → "We decided to..."
2. **One idea per sentence.** If a sentence has "and" connecting two separate thoughts, split it.
3. **Preserve technical accuracy.** Terse ≠ vague. Keep specific numbers, names, versions, constraints. Cut the fluff around them, not the facts.
4. **Match the register.** Technical docs stay technical but tight. Casual stays casual and tight. Don't flatten everything to one voice.
5. **Target 40–60% length reduction.** Under 20% means you didn't cut enough. Over 80% means you lost content.
6. **Inject specificity where the original was vague.** Cutting slop is necessary but not sufficient. Replace "issues" with "errors and latency spikes." Replace "significant growth" with "30% YoY." Replace "leading provider" with the actual name. If the source text has nothing concrete to anchor on, leave the gap visible rather than invent — but flag vague nouns and abstract claims as slop signals.
7. **Prefer numeric constraints over adjectives.** "Three sentences" beats "concise." "Under 100 words" beats "tight." When you instruct yourself or others, use numbers.

---

## Pass 2: Self-audit

After rewriting, review against this checklist. If any item fails, fix it before returning.

1. **Tier 1 words.** Search for every Tier 1 word. If any survived, replace them.
2. **Em dashes.** Count them. More than one per 500 words? Replace extras.
3. **"Not just X, but Y".** Any negative parallelisms? Rewrite as direct statements.
4. **Triplets.** Any rule-of-three patterns? Break them.
5. **False agency.** Inanimate things doing human actions? Fix.
6. **Copula inflation.** Any "serves as", "acts as", "functions as"? Use "is".
7. **Sentence rhythm.** All sentences roughly the same length? Vary them.
8. **Meta-commentary.** Any "In this section...", "As we'll see..."? Delete.
9. **Sycophancy.** Any leftover compliments, "great point", or similar? Delete.
10. **Lexical diversity.** Are most content words unique, or are the same prestige words recurring? AI text has measurably lower type-token ratios. Vary word choice.
11. **Specificity check.** Did you replace at least some vague nouns ("issues," "factors," "things") with concrete ones? If everything is still abstract, the rewrite is incomplete.
12. **Self-critique question.** Read the output back and ask: *"What would make this obviously AI-generated?"* If you can answer, fix that thing. Repeat until you can't.
13. **Substance check (re-run).** Does the polished output actually claim anything? If you stripped slop and ended up with smoothly-written nothing, fall back to the empty-content fallback from Step 1. Don't ship laundered emptiness.

---

## Output format

Return only the rewritten text. No preamble ("Here's the condensed version:"), no postamble ("Let me know if you'd like adjustments!"), no meta-commentary. Just the text.

If the user provides multiple blocks or asks for options, handle accordingly. Default: text in, terse text out.
