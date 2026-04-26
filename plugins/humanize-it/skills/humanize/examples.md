# Humanize: before/after examples

Reference these when calibrating how aggressive a rewrite should be. Each pair shows roughly the target compression ratio (40–60%) and the kinds of substitutions that survive Pass 2.

---

### Example 1 — technical explanation

**Before**
> It's worth noting that when it comes to database performance optimization, there are several key factors that you'll want to carefully consider. First and foremost, indexing plays a crucial role in ensuring that your queries run efficiently. Additionally, you may want to think about query optimization, which involves analyzing and restructuring your SQL statements to minimize execution time. Finally, connection pooling is another important consideration that can significantly impact overall system performance.

**After**
> Database performance hinges on indexing, query structure, and connection pooling. Index your hot queries. Rewrite slow SQL. Pool connections to cut overhead.

*Rules applied:* filler phrase removal ("It's worth noting", "when it comes to", "first and foremost", "additionally", "finally"); meta-commentary stripped; sentence-rhythm variance (three short imperative sentences replace four uniform-length bloated ones).

---

### Example 2 — sycophancy + jargon

**Before**
> Great question! Let me dive into this. When we talk about containerization, it's important to understand that Docker has fundamentally transformed the way we think about application deployment. Essentially, containers provide a lightweight, portable way to package applications along with their dependencies. This is a game-changer because it ensures consistency across different environments, from development to production.

**After**
> Docker packages apps with their dependencies into portable containers. Same environment everywhere: dev, staging, prod.

*Rules applied:* sycophantic opener removed ("Great question!"); meta-commentary cut ("Let me dive into this", "When we talk about"); intensifier deletion ("fundamentally transformed"); Tier 2 word ("game-changer") cut. Two sentences instead of five.

---

### Example 3 — corporate slop with multiple Tier 1/2 words

**Before**
> The new authentication service serves as a cornerstone of our security infrastructure, representing a pivotal shift in how we navigate the complex landscape of identity management. It not only streamlines the login experience but also empowers developers to leverage robust, cutting-edge protocols that foster a more seamless and holistic approach to user verification.

**After**
> The new auth service handles login and identity management. It supports OAuth 2.0 and SAML, and developers can integrate it in under an hour.

*Rules applied:* copula inflation ("serves as" → "is" implicit); Tier 1 word pile-up ("cornerstone", "pivotal", "leverage", "robust", "holistic"); Tier 2 cluster ("navigate the complex landscape", "streamlines", "empowers", "foster", "seamless", "cutting-edge"); specificity injection (replaced vague claims with named protocols and a time estimate).

---

### Example 4 — content-free corporate slop (substance check)

**Before**
> Our platform serves as a comprehensive solution that empowers teams to leverage cutting-edge AI capabilities. The system unlocks unprecedented insights and facilitates seamless collaboration across the organization, fostering a culture of innovation that elevates productivity to new heights.

**After**
> `(no substantive content: marketing copy with no concrete claims, named features, numbers, or falsifiable benefits)`

*Why no rewrite:* every concrete-sounding word is abstract on inspection. There is no platform name, no specific AI capability, no measured insight, no defined collaboration mechanism. A polished short version would still say nothing — just more efficiently. The honest output is to flag the void so the user knows what they have and can decide whether to discard it or go ask for actual content.

If the user follows up with "rewrite anyway," produce the compressed-but-still-empty version (e.g., *"Our AI platform helps teams collaborate and surface insights."*) and note the substance gap.

---

### Example 5 — negative parallelism + significance inflation

**Before**
> It's not just a monitoring tool — it's a comprehensive observability platform that unlocks unprecedented insights into your system's performance, enabling teams to proactively navigate issues before they escalate into critical incidents.

**After**
> It's an observability platform. You can see errors and latency spikes before they become outages.

*Rules applied:* negative parallelism ("not just X — it's Y"); em dash; Tier 1 ("comprehensive", "unprecedented"); Tier 2 ("unlocks", "navigate"); false agency ("enabling teams to proactively navigate" — platforms don't navigate); specificity injection (replaced "issues" and "critical incidents" with named failure modes).

---

### Example 6 — generic metaphors (don't replace, anchor or cut)

**Before**
> Learning the ukulele is like teaching your fingers to dance again after years of sitting still. Every chord is a puzzle piece that finally clicks into a song. Your first strums sound like a toddler learning to talk — nonsense syllables slowly forming words.

**After**
> Learning the ukulele is hard at first. Every new chord takes about thirty attempts before it sounds like the one in your head, and even then your strumming hand is still off-tempo for weeks.

*Rule applied:* generic metaphors. Each of the three source metaphors (fingers dancing, puzzle piece clicking, toddler talking) is plausible but ungrounded — they could attach to any skill-acquisition topic. The rewrite cuts all three and replaces with one concrete observation (thirty attempts, off-tempo strumming) drawn from what actually happens learning the instrument. *Replacing one ungrounded metaphor with another is laundering, not humanizing.* Also kills two em dashes.

---

### Example 7 — unearned profundity + mid-sentence questions + inspirational closer

**Before**
> I learned this the hard way last quarter. Something shifted. Where everyone else saw a setback, I saw an opportunity. The truth? Most teams are looking at the problem backwards. Whatever your "product launch" is — keep iterating.

**After**
> Last quarter we shipped late and lost two enterprise deals. The fix wasn't faster engineering, it was tighter scope: we cut four planned features down to one well-built one, and the next release landed on time.

*Rules applied:* unearned profundity ("Something shifted," "The truth?"), mid-sentence rhetorical question ("The truth?"), inspirational closer ("Whatever your 'product launch' is — keep iterating"), em dash, the implicit negative parallelism ("Where everyone else saw X, I saw Y"). Replaced the entire LinkedIn-lesson scaffold with a specific account: which deals, what fix, what scope change, what outcome.

---

### Example 8 — random bolding + Unicode formatting + emoji bullets

**Before**
> 𝗤𝟯 𝗨𝗽𝗱𝗮𝘁𝗲: We've made **significant progress** on our key initiatives this quarter.
>
> ✅ Shipped the new dashboard
> 📊 Improved analytics reporting
> 💡 Started planning Q4 roadmap
>
> The team has been **working hard** to deliver **real value** for our customers.

**After**
> Q3 update: shipped the new dashboard, improved analytics reporting, started Q4 planning. Still on track for the December release.

*Rules applied:* Unicode pseudo-bold in heading converted to plain ASCII; emoji-led bullet list collapsed into prose (three short bullets weren't earning their formatting); meaningless bolding stripped ("significant progress," "working hard," "real value" — none were the load-bearing claim of the sentence); empty closing replaced with a concrete fact (the December release date) so the message actually says something.

---

### Example 9 — yellow flag (don't over-correct human professional writing)

**Before**
> We need to ascertain the root cause of the latency spike before recommending architectural changes. My read is that it's a connection-pooling issue in the auth service — we saw the same pattern in February when we hit 50k concurrent users for the first time. I'd start by graphing connection acquisition latency for the last week and looking for the bimodal distribution we showed up last time.

**After**
> We need to find the root cause of the latency spike before recommending architectural changes. My read: connection-pooling issue in the auth service. We saw the same pattern in February when we hit 50k concurrent users for the first time. I'd start by graphing connection acquisition latency for the last week and looking for the bimodal distribution we saw last time.

*Why minimal:* the source uses "ascertain" (Tier 1) and one em dash — both technically rule violations. But the writing has *voice* (first-person, opinionated), *concrete facts* (February, 50k users, bimodal distribution, connection acquisition latency), and a clear *point of view* (the author thinks they know the cause). This is professional human writing with a couple of incidental tells, not slop. Yellow-flag rule: don't strip professionalism for its own sake. Edits are limited to (1) replacing "ascertain" with "find" (small readability win, no meaning lost), (2) breaking the em dash into shorter sentences, (3) fixing one typo ("we showed up" → "we saw"). *The voice and content stay intact.* This is what the skill should do when the input isn't actually slop.

---

### Example 10 — Tier 3 density (transitions piling up)

**Before**
> The migration completed successfully. Furthermore, all data integrity checks passed without issue. Moreover, the rollback procedure was tested and verified. Additionally, the new indexes are performing as expected. Notably, query latency dropped by 30%. Ultimately, the project finished two days ahead of schedule.

**After**
> The migration completed successfully. Data integrity checks passed and the rollback procedure was tested. The new indexes are performing as expected, and query latency dropped 30%. We finished two days ahead of schedule.

*Rules applied:* Tier 3 density (six transition-words in six sentences — `furthermore`, `moreover`, `additionally`, `notably`, `ultimately` — each individually fine, but a pile-up at this density is a tell; threshold is 3+ per paragraph). Sentence-rhythm variance (six uniform-length sentences collapsed into four of varying length). Note that no Tier 1 or 2 words were present and the content was already concrete — the *only* slop signal here was the transition density. This is the case Tier 3 is designed for.
