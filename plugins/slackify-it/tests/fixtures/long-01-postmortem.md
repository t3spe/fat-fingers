## Incident Post-mortem: Auth Service Outage on April 24

### Summary

On Thursday April 24 between 14:32 and 15:48 UTC, the auth service experienced a partial outage that caused approximately 12% of login attempts to fail. The root cause was a misconfigured connection pool in the new sessions database, deployed at 14:30.

### Timeline

- 14:30 — Sessions DB connection pool change deployed (PR #4421)
- 14:32 — Error rate on /auth/login begins climbing
- 14:38 — On-call paged
- 14:51 — Root cause identified (pool size of 5 instead of 50)
- 15:12 — Hotfix deployed
- 15:48 — Error rate returns to baseline

### Impact

Roughly 47,000 users experienced one or more failed login attempts during the window. Approximately 800 users abandoned their sessions entirely (per our funnel analytics). No data loss; sessions in flight retried successfully on the second attempt for most users.

### Action Items

1. Add a connection-pool-size sanity check to the sessions deploy pipeline (owner: Maya, due May 1)
2. Improve auth-service alerting threshold from 5% error rate to 1% (owner: Jake, due April 30)
3. Document the hotfix runbook in the auth playbook (owner: Priya, due May 5)

### Lessons

The pool size was an env-var override that didn't get reviewed during the PR. We need a tighter gate on deploy-time env-var changes for the sessions DB. Detection time was acceptable (3 minutes from impact to first alert) but root cause took 13 minutes longer than it should have because we were initially looking at the auth service rather than its DB dependency.
