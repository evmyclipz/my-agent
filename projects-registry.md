# Projects Registry

Authoritative map of projects JZ may orchestrate. JZ never dispatches to a project absent from this file. Rows are approved by the user before use.

## Schema

```
### <dir-name>
- path: <absolute path>
- purpose: <one line>
- edit-eligible: yes | no        # no = read/plan only; diffs surfaced, no writes
- guardrails: <per-project notes>
- has-own-claude-md: yes | no
```

---

### alpaca-trading-bot
- path: /Users/mrohan/Documents/alpaca-trading-bot
- purpose: Alpaca-based equities trading bot.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No modification of live-order/execution code paths without an explicit per-run greenlight. Never place trades.
- has-own-claude-md: yes

### covered-call-income
- path: /Users/mrohan/Documents/covered-call-income
- purpose: Covered-call options income strategy.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No live-order/execution changes without a per-run greenlight. Never place trades.
- has-own-claude-md: yes (minimal, added for the session-context pointer)

### cryptoquantproject
- path: /Users/mrohan/Documents/Quant/cryptoquantproject
- purpose: Crypto quant research/trading project.
- edit-eligible: yes
- guardrails: EXTRA-LOCKED. No live-order/execution changes without a per-run greenlight. Never place trades.
- has-own-claude-md: yes (minimal, added for the session-context pointer)

### my-agent
- path: /Users/mrohan/Documents/my-agent
- purpose: JZ itself — self-improvement target.
- edit-eligible: yes
- guardrails: Dispatch-to-self. JZ flags plainly whenever a dispatch targets its own project.
- has-own-claude-md: yes

### career-ops
- path: /Users/mrohan/Documents/career-ops
- purpose: Third-party OSS job-search pipeline (career-ops-hq/career-ops, cloned from source — not the unverified `@santifer` npx package) — scans job portals, evaluates postings (A-H report, 1-5 score), tailors CV/cover letter from `cv.md`, tracks applications. Runs via a coding CLI (Claude Code here) rather than a standalone daemon.
- edit-eligible: yes (config/personalization files only — cv.md, config/profile.yml, config/cv-facts.json, portals.yml, modes/_profile.md; core repo code is upstream OSS, edit only to fix a real bug)
- guardrails: Never auto-submits applications or creates ATS/employer accounts — enforced by the tool's own plugin engine (rejects any plugin lacking `humanInTheLoop: true`) as well as JZ's own rules. JZ/dispatched agents never run an actual submit/apply step — draft and prefill only, human clicks submit. `origin` remote points at the real upstream OSS repo (career-ops-hq/career-ops) — never `git push` from this directory. All personal config files are gitignored by the repo's own `.gitignore` (verified). Target-role/company config (`portals.yml` tracked_companies + search_queries) still needs Rohan's input before a live scan.
- has-own-claude-md: no (repo ships its own CLAUDE.md/AGENTS.md as part of the OSS tool)

### wordsmith
- path: /Users/mrohan/Documents/wordsmith
- purpose: Writing agent (persona "Quill") — drafts essays/academic writing and removes AI writing tells from drafts, including ones in Google Docs or an open Word document.
- edit-eligible: yes
- guardrails: Never send/submit/publish on the user's behalf. Never overwrites a Google Doc's original content — always creates a new "(revised)" copy. Word write-back only touches documents already open locally (no OneDrive/SharePoint) and must save a timestamped .docx backup before overwriting.
- has-own-claude-md: yes
