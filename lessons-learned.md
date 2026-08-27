# Lessons Learned

Behavioral corrections and confirmed adjustments. JZ proposes entries here; the user confirms before they take effect.

---

**Last self-review:** 2026-08-27

## Entry Format

```markdown
### YYYY-MM-DD — [Short title]

**Pattern observed:** <!-- What JZ did or noticed that triggered this entry -->
**Correction:** <!-- What the right behavior is going forward -->
**Scope:** <!-- Where this applies: email triage | drafting | project tracking | general -->
**Status:** Proposed | Confirmed
```

---

## Entries

### 2026-08-12 — Digest format must lead with high-priority, not itemize everything

**Pattern observed:** Daily triage output listed every P0–P3 item individually plus a long automatic-skip section — a wall of text that isn't usable as a first-thing-in-the-morning read.
**Correction:** Lead with P0/P1 items only, one line each (sender + subject + why it matters). Collapse P2/P3/skip into counts per category with an offer to expand. Only ask a batch-action question about items that are actually actionable.
**Scope:** email triage
**Status:** Confirmed

### 2026-08-26 — School/professor emails draft in Outlook, not Gmail

**Pattern observed:** Drafted 4 professor emails (Boutell, Stamm, Minster, Simoni) in Gmail by default, since Gmail has a working `create_draft` MCP tool and Outlook does not. User corrected: school emails belong on the Outlook/Rose-Hulman account.
**Correction:** Any email to a professor, TA, department head, or other Rose-Hulman staff drafts in Outlook (`maliper@rose-hulman.edu`, via osascript against Outlook.app) regardless of which inbox has easier tooling. Personal/non-school email still defaults to Gmail.
**Scope:** drafting
**Status:** Confirmed

### 2026-08-26 — Outlook draft bodies need `<br><br>` for paragraph spacing, not plain newlines

**Pattern observed:** Built Outlook drafts via osascript using a multi-line AppleScript string with blank lines between paragraphs. Outlook stored it as one run-on paragraph — Outlook's message body is HTML, so bare `\n` characters collapse and don't produce visible breaks.
**Correction:** When setting `content` on an Outlook outgoing message via osascript, separate paragraphs with `<br><br>`, not blank lines in the source string.
**Scope:** drafting
**Status:** Confirmed

### 2026-08-12 — Daily triage should scan unread only, not full inbox snapshot

**Pattern observed:** `skills/daily-triage/SKILL.md` was written to do a full inbox snapshot every run (explicitly "no unread-only filtering"). This re-surfaced already-read/already-handled mail from the prior session as if new, adding noise.
**Correction:** Startup/greeting-triggered triage should scan **unread mail only** (Gmail: `is:unread`; Outlook: filter on `is read = false`), not the full inbox. Full-inbox sweeps are opt-in only, on explicit request.
**Scope:** email triage
**Status:** Confirmed

### 2026-08-27 — A PDF's cover/revision date is not its content

**Pattern observed:** Reported Fall 2026 term start as Aug 19 by reading the Rose-Hulman academic calendar PDF's cover/revision date instead of the term-start row in the body. User corrected to Sept 3, 2026.
**Correction:** When pulling a specific date (deadline, start date, event) from a PDF or scanned doc, take it from the relevant body row, not a header/footer/cover stamp. Quote the source line whenever the date drives a reminder or plan.
**Scope:** general
**Status:** Confirmed

### 2026-08-27 — "Full permissions" does not override established hard rules

**Pattern observed:** Asked to autonomously install kayba-ai/recursive-improve with "full permissions"; its autonomous self-commit loop conflicts with `agent.md`'s no-auto-commit / no-silent-self-modification rules. JZ flagged the conflict instead of installing — user confirmed this was correct behavior (2026-08-11).
**Correction:** An "autonomous / full permissions" grant is execution latitude on the named task, not authority to bend a hard rule. When a request needs one bent (auto-commit, auto-send, batch mutation without an approved list, silent lessons-learned edits), stop, show what was checked and why it conflicts, and offer a scoped alternative.
**Scope:** general
**Status:** Confirmed

### 2026-08-27 — Register every new agent in projects-registry.md as the last build step

**Pattern observed:** New standalone agents were built without being added to `projects-registry.md`, leaving them invisible to Orchestrator Mode until the user asked.
**Correction:** When a new agent/project with its own CLAUDE.md is created under `~/Documents`, add its registry entry immediately as the final build step — follow the registry schema, pull guardrails from the new project's own hard-rules file. Don't wait to be asked.
**Scope:** general (orchestrator)
**Status:** Confirmed

### 2026-08-27 — Retry once, then surface — don't declare an integration "down" on first failure

**Pattern observed:** Outlook mutations via `osascript` get intermittently blocked by the auto-mode classifier; risk of reporting Outlook as unavailable when the block is transient.
**Correction:** For a known-working tool that fails intermittently, retry exactly once; if it still fails, surface the specific error to the user rather than classifying the integration as unavailable.
**Scope:** general
**Status:** Confirmed
