# Humanize: before/after examples

Reference these when calibrating how aggressive a rewrite should be. Each pair shows roughly the target compression ratio (40–60%) and the kinds of substitutions that survive Pass 2.

---

### Example 1 — technical explanation

**Before**
> It's worth noting that when it comes to database performance optimization, there are several key factors that you'll want to carefully consider. First and foremost, indexing plays a crucial role in ensuring that your queries run efficiently. Additionally, you may want to think about query optimization, which involves analyzing and restructuring your SQL statements to minimize execution time. Finally, connection pooling is another important consideration that can significantly impact overall system performance.

**After**
> Database performance hinges on indexing, query structure, and connection pooling. Index your hot queries. Rewrite slow SQL. Pool connections to cut overhead.

*What got cut:* "It's worth noting", "when it comes to", "first and foremost", "additionally", "finally", and the explanatory padding around each item. Three short imperative sentences replace four bloated ones.

---

### Example 2 — sycophancy + jargon

**Before**
> Great question! Let me dive into this. When we talk about containerization, it's important to understand that Docker has fundamentally transformed the way we think about application deployment. Essentially, containers provide a lightweight, portable way to package applications along with their dependencies. This is a game-changer because it ensures consistency across different environments, from development to production.

**After**
> Docker packages apps with their dependencies into portable containers. Same environment everywhere: dev, staging, prod.

*What got cut:* sycophantic opener, "let me dive into this", "fundamentally transformed", "game-changer", and the throat-clearing "When we talk about". Two sentences instead of five.

---

### Example 3 — corporate slop with multiple Tier 1/2 words

**Before**
> The new authentication service serves as a cornerstone of our security infrastructure, representing a pivotal shift in how we navigate the complex landscape of identity management. It not only streamlines the login experience but also empowers developers to leverage robust, cutting-edge protocols that foster a more seamless and holistic approach to user verification.

**After**
> The new auth service handles login and identity management. It supports OAuth 2.0 and SAML, and developers can integrate it in under an hour.

*What got cut:* "serves as a cornerstone" (copula inflation + Tier 1), "pivotal shift" (Tier 1), "navigate the complex landscape" (Tier 2 cluster), "streamlines / empowers / leverage / robust / cutting-edge / foster / seamless / holistic" (Tier 1+2 pile-up). Replaced vague claims with concrete protocols and a time estimate.

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

*What got cut:* "not just X — it's Y" negative parallelism, em dash, "comprehensive", "unlocks unprecedented insights" (Tier 1+2), "enabling teams to proactively navigate" (false agency + Tier 2). Replaced "issues" and "critical incidents" with concrete examples.
